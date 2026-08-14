import 'package:flutter_test/flutter_test.dart';
import 'package:aura_echo/main.dart';
import 'package:aura_echo/services/sensor_service.dart';

void main() {
  testWidgets('AuraEchoApp boots and renders navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const AuraEchoApp());
    expect(find.text('Boshqaruv'), findsOneWidget);
    SensorService().stopTelemetry();
    await tester.pumpAndSettle();
  });
}
