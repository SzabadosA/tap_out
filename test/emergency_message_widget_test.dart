import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_out/emergency_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmergencyMessageWidget', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('loads and displays the saved message',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('emergency_message', 'Test message');

      await tester.pumpWidget(const MaterialApp(
        home: EmergencyMessageWidget(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('displays default message if no saved message',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: EmergencyMessageWidget(),
      ));

      await tester.pumpAndSettle();

      expect(
          find.text('I am in danger. Please get help. I am at this location: '),
          findsOneWidget);
    });

    testWidgets('saves and updates the message', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: EmergencyMessageWidget(),
      ));

      await tester.enterText(find.byType(TextField), 'New emergency message');
      await tester.tap(find.text('Save Message'));

      await tester.pumpAndSettle();

      expect(
          find.text('Current Message: New emergency message'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('emergency_message'), 'New emergency message');
    });
  });
}
