import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_out/contacts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContactsPage', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('loads and displays contacts', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('contacts', ['John Doe|1234567890']);

      await tester.pumpWidget(const MaterialApp(
        home: ContactsPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
    });

    testWidgets('displays empty list if no contacts are saved',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ContactsPage(),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('adds a new contact', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ContactsPage(),
      ));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Jane Doe');
      await tester.enterText(find.byType(TextField).at(1), '0987654321');
      await tester.tap(find.text('Add'));

      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('0987654321'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('contacts'), ['Jane Doe|0987654321']);
    });

    testWidgets('removes a contact', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('contacts', ['John Doe|1234567890']);

      await tester.pumpWidget(const MaterialApp(
        home: ContactsPage(),
      ));

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsNothing);
      expect(find.text('1234567890'), findsNothing);

      expect(prefs.getStringList('contacts'), []);
    });
  });
}
