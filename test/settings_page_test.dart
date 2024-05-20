import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tap_out/contacts.dart';
import 'package:tap_out/emergency_message.dart';
import 'package:tap_out/pattern_recognition.dart';
import 'package:tap_out/settings_page.dart';

class MockPeakDetectionNotifier extends Mock implements PeakDetectionNotifier {}

void main() {
  late MockPeakDetectionNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockPeakDetectionNotifier();
  });

  Future<void> _buildSettingsPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<PeakDetectionNotifier>.value(
        value: mockNotifier,
        child: const MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );
  }

  testWidgets('SettingsPage has a title and list tiles',
      (WidgetTester tester) async {
    await _buildSettingsPage(tester);

    // Verify the title
    expect(find.text('Settings'), findsOneWidget);

    // Verify the list tiles
    expect(find.text('Deactivate Session'), findsOneWidget);
    expect(find.text('Edit Contacts'), findsOneWidget);
    expect(find.text('Edit Message'), findsOneWidget);
  });

  testWidgets('Tapping Deactivate Session calls resetPatternDetection',
      (WidgetTester tester) async {
    await _buildSettingsPage(tester);

    // Tap the Deactivate Session tile
    await tester.tap(find.text('Deactivate Session'));
    await tester.pump();

    // Verify that resetPatternDetection was called
    verify(mockNotifier.resetPatternDetection()).called(1);
  });

  testWidgets('Tapping Edit Contacts navigates to ContactsPage',
      (WidgetTester tester) async {
    await _buildSettingsPage(tester);

    // Tap the Edit Contacts tile
    await tester.tap(find.text('Edit Contacts'));
    await tester.pumpAndSettle();

    // Verify navigation to ContactsPage
    expect(find.byType(ContactsPage), findsOneWidget);
  });

  testWidgets('Tapping Edit Message navigates to EmergencyMessageWidget',
      (WidgetTester tester) async {
    await _buildSettingsPage(tester);

    // Tap the Edit Message tile
    await tester.tap(find.text('Edit Message'));
    await tester.pumpAndSettle();

    // Verify navigation to EmergencyMessageWidget
    expect(find.byType(EmergencyMessageWidget), findsOneWidget);
  });
}
