// 여러 화면에서 재사용하는 Flutter 위젯 파일입니다.
// 부모 화면에서 받은 값과 콜백을 바탕으로 UI를 구성합니다.

import 'package:flutter/material.dart';

import '../controllers/event_feed_source.dart';
import '../models/event_log_item.dart';

// 이벤트 목록 패널입니다.
// 파일 로그 모드와 API 모드 모두 EventFeedSource만 맞으면 같은 UI를 재사용합니다.
class EventLogBox extends StatefulWidget {
  const EventLogBox({
    super.key,
    required this.eventFeed,
    required this.baseUrl,
    required this.onTapItem,
    this.sourceLabelResolver,
    this.onDateRangeChanged,
  });

  final EventFeedSource eventFeed;
  final String baseUrl;
  final void Function(EventLogItem item) onTapItem;
  final String Function(String sourceKey)? sourceLabelResolver;
  final void Function(DateTime? startDate, DateTime? endDate)?
  onDateRangeChanged;

  @override
  State<EventLogBox> createState() => _EventLogBoxState();
}

class _EventLogBoxState extends State<EventLogBox> {
  final ScrollController _scrollController = ScrollController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = widget.eventFeed.logItems;
    final items = allItems.where(_matchesDateRange).toList(growable: false);
    final hasDateFilter = _startDate != null || _endDate != null;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171A20),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '이벤트 로그',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      hasDateFilter
                          ? '총 ${items.length}/${allItems.length}건'
                          : '총 ${items.length}건',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDateFilterBar(context),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('표시할 로그가 없습니다.'))
                : Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _LogTile(
                          item: item,
                          baseUrl: widget.baseUrl,
                          isSelected: widget.eventFeed.selectedKeys.contains(
                            item.selectionKey,
                          ),
                          onTap: () => widget.onTapItem(item),
                          sourceLabelResolver: widget.sourceLabelResolver,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterBar(BuildContext context) {
    final hasDateFilter = _startDate != null || _endDate != null;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _DateFilterButton(
          tooltip: '시작 날짜/시간 선택',
          label: _formatDateTimeLabel(_startDate, fallback: '시작'),
          onPressed: () => _pickDateTime(context, isStart: true),
        ),
        Text('~', style: Theme.of(context).textTheme.bodySmall),
        _DateFilterButton(
          tooltip: '종료 날짜/시간 선택',
          label: _formatDateTimeLabel(_endDate, fallback: '종료'),
          onPressed: () => _pickDateTime(context, isStart: false),
        ),
        if (hasDateFilter)
          TextButton.icon(
            onPressed: _clearDateFilter,
            icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
            label: const Text('해제'),
          ),
      ],
    );
  }

  Future<void> _pickDateTime(
    BuildContext context, {
    required bool isStart,
  }) async {
    final now = DateTime.now();
    final fallbackDate = DateTime(now.year, now.month, now.day);
    final currentValue = isStart ? _startDate : _endDate;
    final pairedValue = isStart ? _endDate : _startDate;
    final initialValue =
        currentValue ??
        (isStart
            ? fallbackDate
            : DateTime(
                fallbackDate.year,
                fallbackDate.month,
                fallbackDate.day + 1,
              ));
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return _DateTimeRangePointDialog(
          title: isStart ? '시작 날짜 선택' : '종료 날짜 선택',
          initialValue: initialValue,
          firstDate: DateTime(2020),
          lastDate: DateTime(now.year + 5, 12, 31),
          minimumValue: isStart ? null : pairedValue,
          maximumValue: isStart ? pairedValue : null,
          preferEndOfDay: !isStart && currentValue == null,
        );
      },
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && !_endDate!.isAfter(_startDate!)) {
          _endDate = _startDate!.add(const Duration(minutes: 30));
        }
      } else {
        _endDate = picked;
      }
    });
    widget.onDateRangeChanged?.call(_startDate, _endDate);
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    widget.onDateRangeChanged?.call(null, null);
  }

  bool _matchesDateRange(EventLogItem item) {
    if (_startDate == null && _endDate == null) {
      return true;
    }
    final parsed = DateTime.tryParse(item.timeText.trim());
    if (parsed == null) {
      return false;
    }
    final itemTime = parsed.toLocal();
    if (_startDate != null && itemTime.isBefore(_startDate!)) {
      return false;
    }
    if (_endDate != null && !itemTime.isBefore(_endDate!)) {
      return false;
    }
    return true;
  }

  String _formatDateTimeLabel(DateTime? value, {required String fallback}) {
    if (value == null) {
      return fallback;
    }
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year.$month.$day $hour:$minute';
  }
}

class _DateTimeRangePointDialog extends StatefulWidget {
  const _DateTimeRangePointDialog({
    required this.title,
    required this.initialValue,
    required this.firstDate,
    required this.lastDate,
    this.minimumValue,
    this.maximumValue,
    this.preferEndOfDay = false,
  });

  final String title;
  final DateTime initialValue;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? minimumValue;
  final DateTime? maximumValue;
  final bool preferEndOfDay;

  @override
  State<_DateTimeRangePointDialog> createState() =>
      _DateTimeRangePointDialogState();
}

class _DateTimeRangePointDialogState extends State<_DateTimeRangePointDialog> {
  late DateTime _selectedDate;
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialValue.year,
      widget.initialValue.month,
      widget.initialValue.day,
    );
    _selectedHour = widget.preferEndOfDay ? 24 : widget.initialValue.hour;
    _selectedMinute = _selectedHour == 24 ? 0 : widget.initialValue.minute;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final candidate = _selectedDateTime();
    final isValid = _isValid(candidate);
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      title: Text(widget.title),
      content: SizedBox(
        width: 390,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateSummary(value: candidate),
            const SizedBox(height: 10),
            CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: _dateOnly(widget.firstDate),
              lastDate: _dateOnly(widget.lastDate),
              onDateChanged: (value) {
                setState(() {
                  _selectedDate = DateTime(value.year, value.month, value.day);
                });
              },
            ),
            const Divider(height: 18),
            Row(
              children: [
                const Icon(Icons.schedule, size: 18),
                const SizedBox(width: 8),
                const Text('시간'),
                const Spacer(),
                _TimeDropdown<int>(
                  value: _selectedHour,
                  values: List<int>.generate(25, (index) => index),
                  labelBuilder: (value) => value.toString().padLeft(2, '0'),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedHour = value;
                      if (_selectedHour == 24) {
                        _selectedMinute = 0;
                      }
                    });
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(':'),
                ),
                _TimeDropdown<int>(
                  value: _selectedMinute,
                  values: _selectedHour == 24 ? const [0] : const [0, 30],
                  labelBuilder: (value) => value.toString().padLeft(2, '0'),
                  onChanged: _selectedHour == 24
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedMinute = value;
                          });
                        },
                ),
              ],
            ),
            if (!isValid) ...[
              const SizedBox(height: 8),
              Text(
                '종료 시간은 시작 시간보다 이후여야 합니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: isValid
              ? () => Navigator.of(context).pop(candidate)
              : null,
          child: const Text('적용'),
        ),
      ],
    );
  }

  DateTime _selectedDateTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedHour,
      _selectedMinute,
    );
  }

  bool _isValid(DateTime value) {
    final minimum = widget.minimumValue;
    if (minimum != null && !value.isAfter(minimum)) {
      return false;
    }
    final maximum = widget.maximumValue;
    if (maximum != null && !value.isBefore(maximum)) {
      return false;
    }
    return true;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _DateSummary extends StatelessWidget {
  const _DateSummary({required this.value});

  final DateTime value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = [
      ('년', value.year.toString().padLeft(4, '0')),
      ('월', value.month.toString().padLeft(2, '0')),
      ('일', value.day.toString().padLeft(2, '0')),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                '${row.$1} ${row.$2}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeDropdown<T> extends StatelessWidget {
  const _TimeDropdown({
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      items: values
          .map(
            (value) => DropdownMenuItem<T>(
              value: value,
              child: Text(labelBuilder(value)),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.tooltip,
    required this.label,
    required this.onPressed,
  });

  final String tooltip;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.calendar_month_outlined, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({
    required this.item,
    required this.baseUrl,
    required this.isSelected,
    required this.onTap,
    this.sourceLabelResolver,
  });

  final EventLogItem item;
  final String baseUrl;
  final bool isSelected;
  final VoidCallback onTap;
  final String Function(String sourceKey)? sourceLabelResolver;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumbnailUrl = _resolveThumbnailUrl(item.thumbnailUrlText);
    return Material(
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EventThumbnail(url: thumbnailUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ruleLabel(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _MetaLine(
                      icon: Icons.schedule,
                      text: '발생시간 ${_compactDateTime(item.timeText)}',
                    ),
                    const SizedBox(height: 3),
                    _MetaLine(
                      icon: Icons.computer,
                      text: '클라이언트 ${_clientLabel(item.sourceKeyText)}',
                    ),
                    const SizedBox(height: 3),
                    _MetaLine(
                      icon: Icons.policy_outlined,
                      text: '탐지 룰 ${_ruleLabel(item)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveThumbnailUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return '';
    }
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return trimmed;
    }
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    if (trimmed.startsWith('/')) {
      return '$normalizedBase$trimmed';
    }
    return '$normalizedBase/$trimmed';
  }

  String _compactDateTime(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return '-';
    }
    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) {
      return trimmed;
    }
    final local = parsed.toLocal();
    return '${local.year}.${local.month.toString().padLeft(2, '0')}.${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }

  String _clientLabel(String sourceKey) {
    final resolved = sourceLabelResolver?.call(sourceKey).trim() ?? '';
    if (resolved.isNotEmpty) {
      return resolved;
    }
    final match = RegExp(r'owner=([^|]+)').firstMatch(sourceKey);
    final owner = match?.group(1)?.trim() ?? '';
    if (owner.isEmpty) {
      return '-';
    }
    return owner.replaceFirst(RegExp(r'^client_'), '');
  }

  String _ruleLabel(EventLogItem item) {
    final type = item.typeText.trim();
    final level = item.levelText.trim();
    if (type.isEmpty || type == '-') {
      return level.isEmpty || level == '-' ? '-' : level;
    }
    if (level.isEmpty || level == '-') {
      return type;
    }
    return '$type / $level';
  }
}

class _EventThumbnail extends StatelessWidget {
  const _EventThumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 96,
        height: 64,
        color: Colors.black26,
        child: url.isEmpty
            ? const _ThumbnailPlaceholder()
            : Image.network(
                url,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return const _ThumbnailPlaceholder();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return const _ThumbnailPlaceholder(isLoading: true);
                },
              ),
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder({this.isLoading = false});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        isLoading ? Icons.image_search : Icons.image_not_supported_outlined,
        color: Colors.white38,
        size: 22,
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.white54),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
