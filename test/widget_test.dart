import 'package:flutter_test/flutter_test.dart';
import 'package:marks_app/main.dart';

void main() {
  testWidgets('SmartMark App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartMarkApp());
    expect(find.byType(SmartMarkApp), findsOneWidget);
  });
}
