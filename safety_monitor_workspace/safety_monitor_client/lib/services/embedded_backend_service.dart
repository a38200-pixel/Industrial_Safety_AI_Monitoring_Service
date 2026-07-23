// Flutter 쪽에서 서버 API나 로컬 프로세스 같은 외부 기능을 호출하는 파일입니다.
// HTTP 주소 생성, 요청 전송, 응답 JSON 변환 흐름이 포함되어 있습니다.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class EmbeddedBackendService extends ChangeNotifier {
  EmbeddedBackendService._();

  static final EmbeddedBackendService instance = EmbeddedBackendService._();

  static const String localBaseUrl = 'http://127.0.0.1:8100';
  static const Duration _healthTimeout = Duration(seconds: 20);
  static const Duration _pollInterval = Duration(milliseconds: 500);

  Process? _backendProcess;
  IOSink? _logSink;
  Timer? _shutdownTimer;
  bool _isStarting = false;
  bool _isRunning = false;
  bool _isPreparingEngine = false;
  String _lastErrorMessage = '';
  String _logFilePath = '';
  String _engineProgressMessage = '';

  bool get isStarting => _isStarting;
  bool get isRunning => _isRunning;
  bool get isPreparingEngine => _isPreparingEngine;
  String get lastErrorMessage => _lastErrorMessage;
  String get logFilePath => _logFilePath;
  String get engineProgressMessage => _engineProgressMessage;

  Future<void> ensureStarted() async {
    _shutdownTimer?.cancel();
    _shutdownTimer = null;

    final projectRoot = _findClientProjectRoot();
    if (projectRoot == null) {
      _setError('Client project root could not be resolved.');
      return;
    }

    _logFilePath = _join(projectRoot.path, 'embedded_backend_runtime.log');
    if (await _isHealthy()) {
      await _syncRemoteServerUrlFromSettings(projectRoot);
      _isRunning = true;
      _lastErrorMessage = '';
      notifyListeners();
      return;
    }

    if (_isStarting) {
      final ok = await _waitForHealth();
      if (!ok) {
        _setError('Embedded backend did not become healthy.');
      }
      return;
    }

    _isStarting = true;
    _isRunning = false;
    _lastErrorMessage = '';
    notifyListeners();

    try {
      await _terminateTrackedProcessIfNeeded(projectRoot);

      final backendDir = Directory(_join(projectRoot.path, 'embedded_backend'));
      final backendEntry = File(_join(backendDir.path, 'main.py'));
      final yoloConfigDir = _join(backendDir.path, 'data', 'ultralytics');
      Directory(yoloConfigDir).createSync(recursive: true);
      if (!backendEntry.existsSync()) {
        _setError('Embedded backend entry file was not found.');
        return;
      }

      final pythonExecutable = _findPythonExecutable(projectRoot);
      if (pythonExecutable == null) {
        _setError('Python executable for the embedded backend was not found.');
        return;
      }

      final engineReady = await _prepareRuntimeEngineIfNeeded(
        projectRoot: projectRoot,
        pythonExecutable: pythonExecutable,
      );
      if (!engineReady) {
        return;
      }

      final remoteServerUrl = _readRemoteServerUrl(projectRoot);
      final logFile = File(_logFilePath);
      logFile.parent.createSync(recursive: true);
      _logSink?.close();
      _logSink = logFile.openWrite(mode: FileMode.writeOnlyAppend);
      _writeLog('=== starting embedded backend ===');
      _writeLog('python=$pythonExecutable');
      _writeLog('backendDir=${backendDir.path}');
      if (remoteServerUrl.isNotEmpty) {
        _writeLog('remoteServer=$remoteServerUrl');
      }

      final process = await Process.start(
        pythonExecutable,
        const [
          '-m',
          'uvicorn',
          'main:app',
          '--host',
          '127.0.0.1',
          '--port',
          '8100',
          '--no-access-log',
        ],
        workingDirectory: backendDir.path,
        runInShell: false,
        environment: {
          ...Platform.environment,
          if (remoteServerUrl.isNotEmpty)
            'SAFETY_MONITOR_SERVER_URL': remoteServerUrl,
          'YOLO_CONFIG_DIR': yoloConfigDir,
        },
      );
      _backendProcess = process;
      await _writePidFile(projectRoot, process.pid);
      _attachLogging(process);

      final ok = await _waitForHealth();
      if (!ok) {
        _setError(
          'Embedded backend failed to start. Check $logFilePath for details.',
        );
        await shutdown();
        return;
      }

      _isRunning = true;
      _lastErrorMessage = '';
      await _syncRemoteServerUrlFromSettings(projectRoot);
      notifyListeners();
    } catch (error) {
      _setError('Embedded backend startup failed: $error');
    } finally {
      _isStarting = false;
      notifyListeners();
    }
  }

  Future<bool> _prepareRuntimeEngineIfNeeded({
    required Directory projectRoot,
    required String pythonExecutable,
  }) async {
    final backendDir = Directory(_join(projectRoot.path, 'embedded_backend'));
    final enginePath = File(
      _join(
        backendDir.path,
        'app',
        'analysis',
        'models',
        'weights',
        'best.engine',
      ),
    );
    if (enginePath.existsSync()) {
      return true;
    }

    final prepareScript = File(
      _join(backendDir.path, 'ensure_runtime_engine.py'),
    );
    if (!prepareScript.existsSync()) {
      _setError('TensorRT engine preparation script was not found.');
      return false;
    }

    _isPreparingEngine = true;
    _engineProgressMessage = 'TensorRT engine 생성 중입니다. 첫 실행에서는 시간이 걸릴 수 있습니다.';
    notifyListeners();

    try {
      final process = await Process.start(
        pythonExecutable,
        [prepareScript.path],
        workingDirectory: backendDir.path,
        runInShell: false,
        environment: {
          ...Platform.environment,
          'YOLO_CONFIG_DIR': _join(backendDir.path, 'data', 'ultralytics'),
        },
      );
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.trim().isEmpty) {
              return;
            }
            _engineProgressMessage = line.trim();
            _writeLog('ENGINE $line');
            notifyListeners();
          });
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.trim().isEmpty) {
              return;
            }
            _engineProgressMessage = line.trim();
            _writeLog('ENGINE ERR $line');
            notifyListeners();
          });

      final exitCode = await process.exitCode;
      if (exitCode != 0 || !enginePath.existsSync()) {
        _setError('TensorRT engine 생성에 실패했습니다. 로그를 확인해 주세요.');
        return false;
      }
      return true;
    } catch (error) {
      _setError('TensorRT engine 생성 중 오류가 발생했습니다: $error');
      return false;
    } finally {
      _isPreparingEngine = false;
      _engineProgressMessage = '';
      notifyListeners();
    }
  }

  Future<void> shutdown() async {
    _shutdownTimer?.cancel();
    _shutdownTimer = null;

    final process = _backendProcess;
    _backendProcess = null;
    _isRunning = false;
    _isPreparingEngine = false;
    notifyListeners();

    if (process != null) {
      try {
        process.kill(ProcessSignal.sigterm);
      } catch (_) {
        try {
          process.kill();
        } catch (_) {
          // Ignore shutdown failures on app exit.
        }
      }
    }

    try {
      final projectRoot = _findClientProjectRoot();
      if (projectRoot != null) {
        final pidFile = File(_join(projectRoot.path, 'embedded_backend.pid'));
        if (pidFile.existsSync()) {
          pidFile.deleteSync();
        }
      }
    } catch (_) {
      // Ignore pid cleanup failures.
    }
  }

  void scheduleShutdown({Duration delay = const Duration(seconds: 5)}) {
    _shutdownTimer?.cancel();
    _shutdownTimer = Timer(delay, () {
      _shutdownTimer = null;
      unawaited(shutdown());
    });
  }

  Future<bool> _waitForHealth() async {
    final deadline = DateTime.now().add(_healthTimeout);
    while (DateTime.now().isBefore(deadline)) {
      if (await _isHealthy()) {
        return true;
      }
      await Future<void>.delayed(_pollInterval);
    }
    return false;
  }

  Future<bool> _isHealthy() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    try {
      final request = await client.getUrl(Uri.parse('$localBaseUrl/health'));
      final response = await request.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _syncRemoteServerUrlFromSettings(Directory projectRoot) async {
    final remoteServerUrl = _readRemoteServerUrl(projectRoot);
    if (remoteServerUrl.isEmpty) {
      return;
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    try {
      final request = await client
          .putUrl(Uri.parse('$localBaseUrl/api/admin/remote-server'))
          .timeout(const Duration(seconds: 2));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'remote_server_base_url': remoteServerUrl}));
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _writeLog('synced remoteServer=$remoteServerUrl');
      } else {
        _writeLog(
          'remote server sync returned HTTP ${response.statusCode}: $remoteServerUrl',
        );
      }
    } catch (error) {
      _writeLog('remote server sync failed: $error');
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _terminateTrackedProcessIfNeeded(Directory projectRoot) async {
    final pidFile = File(_join(projectRoot.path, 'embedded_backend.pid'));
    if (!pidFile.existsSync()) {
      return;
    }

    final rawPid = pidFile.readAsStringSync().trim();
    final pid = int.tryParse(rawPid);
    if (pid == null) {
      pidFile.deleteSync();
      return;
    }

    if (await _isHealthy()) {
      return;
    }

    try {
      Process.killPid(pid, ProcessSignal.sigterm);
    } catch (_) {
      try {
        Process.killPid(pid);
      } catch (_) {
        // Ignore failures when the old process is already gone.
      }
    }
    pidFile.deleteSync();
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  Future<void> _writePidFile(Directory projectRoot, int pid) async {
    final pidFile = File(_join(projectRoot.path, 'embedded_backend.pid'));
    await pidFile.writeAsString('$pid', flush: true);
  }

  void _attachLogging(Process process) {
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => _writeLog(line));
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => _writeLog('ERR $line'));
    unawaited(
      process.exitCode.then((exitCode) {
        _writeLog('embedded backend exited with code $exitCode');
        if (_backendProcess == process) {
          _backendProcess = null;
          _isRunning = false;
          notifyListeners();
        }
      }),
    );
  }

  void _writeLog(String line) {
    final sink = _logSink;
    if (sink == null) {
      return;
    }
    sink.writeln('${DateTime.now().toIso8601String()} $line');
  }

  void _setError(String message) {
    _lastErrorMessage = message;
    _isRunning = false;
    notifyListeners();
  }

  Directory? _findClientProjectRoot() {
    final roots = <Directory>{
      Directory.current,
      File(Platform.resolvedExecutable).parent,
    };
    for (final root in roots) {
      Directory? current = root.absolute;
      for (var depth = 0; depth < 8 && current != null; depth++) {
        final backendEntry = File(
          _join(current.path, 'embedded_backend', 'main.py'),
        );
        if (backendEntry.existsSync()) {
          return current;
        }
        current = current.parent.path == current.path ? null : current.parent;
      }
    }
    return null;
  }

  String? _findPythonExecutable(Directory projectRoot) {
    final workspaceRoot = projectRoot.parent;
    final candidates = <String>[
      _join(workspaceRoot.path, '.venv', 'Scripts', 'python.exe'),
      _join(workspaceRoot.path, '.venv', 'Scripts', 'pythonw.exe'),
      _join(workspaceRoot.path, '.venv', 'Scripts', 'py.exe'),
    ];
    for (final candidate in candidates) {
      if (File(candidate).existsSync()) {
        return candidate;
      }
    }
    return null;
  }

  String _readRemoteServerUrl(Directory projectRoot) {
    final settingsFile = File(_join(projectRoot.path, 'client_settings.json'));
    if (!settingsFile.existsSync()) {
      return '';
    }
    try {
      final decoded = jsonDecode(settingsFile.readAsStringSync());
      if (decoded is! Map<String, dynamic>) {
        return '';
      }
      final value = decoded['remote_server_base_url']?.toString().trim() ?? '';
      return value;
    } catch (_) {
      return '';
    }
  }

  String _join(
    String first,
    String second, [
    String? third,
    String? fourth,
    String? fifth,
    String? sixth,
  ]) {
    final parts = <String>[first, second, ?third, ?fourth, ?fifth, ?sixth];
    return parts.join(Platform.pathSeparator);
  }
}
