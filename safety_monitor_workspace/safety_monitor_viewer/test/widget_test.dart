import 'package:flutter_test/flutter_test.dart';

import 'package:safety_monitor_viewer/app.dart';

void main() {
  testWidgets('viewer app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const SafetyMonitorViewerApp());
    expect(find.text('Safety Monitor Viewer'), findsOneWidget);
  });
}
