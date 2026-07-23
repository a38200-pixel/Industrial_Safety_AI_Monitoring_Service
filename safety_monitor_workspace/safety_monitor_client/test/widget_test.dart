import 'package:flutter_test/flutter_test.dart';

import 'package:safety_monitor_client/app.dart';

void main() {
  testWidgets('client app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const SafetyMonitorClientApp());
    expect(find.text('Safety Monitor Client'), findsOneWidget);
  });
}
