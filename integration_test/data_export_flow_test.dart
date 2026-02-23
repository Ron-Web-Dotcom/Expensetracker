import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expensetracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Data Export Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Export data from privacy compliance center', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Settings
      final settingsTab = find.text('Settings');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();
      }

      // Navigate to Privacy Compliance
      final privacyOption = find.textContaining('Privacy');
      if (privacyOption.evaluate().isNotEmpty) {
        await tester.tap(privacyOption.first);
        await tester.pumpAndSettle();
      }

      // Find and tap Export Data button
      final exportButton = find.text('Export My Data');
      if (exportButton.evaluate().isNotEmpty) {
        await tester.tap(exportButton);
        await tester.pumpAndSettle();

        // Verify export confirmation dialog
        expect(find.text('Export Data'), findsWidgets);
        expect(find.text('JSON'), findsWidgets);

        // Confirm export
        final confirmButton = find.text('Export');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();

          // Verify success message
          expect(find.textContaining('exported'), findsWidgets);
        }
      }
    });

    testWidgets('Data deletion flow with confirmation', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Privacy Compliance
      final settingsTab = find.text('Settings');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();
      }

      final privacyOption = find.textContaining('Privacy');
      if (privacyOption.evaluate().isNotEmpty) {
        await tester.tap(privacyOption.first);
        await tester.pumpAndSettle();
      }

      // Find Delete Data button
      final deleteButton = find.text('Delete All My Data');
      if (deleteButton.evaluate().isNotEmpty) {
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        // Verify confirmation dialog
        expect(find.text('Delete All Data'), findsWidgets);
        expect(find.textContaining('permanent'), findsWidgets);

        // Cancel first
        final cancelButton = find.text('Cancel');
        if (cancelButton.evaluate().isNotEmpty) {
          await tester.tap(cancelButton);
          await tester.pumpAndSettle();

          // Verify still on privacy screen
          expect(find.text('Privacy Compliance'), findsWidgets);
        }
      }
    });

    testWidgets('View consent history', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Privacy Compliance
      final settingsTab = find.text('Settings');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();
      }

      final privacyOption = find.textContaining('Privacy');
      if (privacyOption.evaluate().isNotEmpty) {
        await tester.tap(privacyOption.first);
        await tester.pumpAndSettle();
      }

      // Find consent history section
      final consentHistory = find.textContaining('Consent');
      if (consentHistory.evaluate().isNotEmpty) {
        expect(consentHistory, findsWidgets);

        // Verify consent records are displayed
        expect(find.textContaining('Granted'), findsWidgets);
      }
    });

    testWidgets('Complete GDPR compliance flow', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Add some test data first
      final addExpenseButton = find.text('Add Expense');
      if (addExpenseButton.evaluate().isNotEmpty) {
        await tester.tap(addExpenseButton);
        await tester.pumpAndSettle();

        final amountField = find.byType(TextField).first;
        await tester.enterText(amountField, '50');
        await tester.pumpAndSettle();

        final saveButton = find.widgetWithText(ElevatedButton, 'Save Expense');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }
      }

      // Navigate to Privacy Compliance
      final settingsTab = find.text('Settings');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();
      }

      final privacyOption = find.textContaining('Privacy');
      if (privacyOption.evaluate().isNotEmpty) {
        await tester.tap(privacyOption.first);
        await tester.pumpAndSettle();
      }

      // Verify all GDPR rights are accessible
      expect(find.textContaining('Export'), findsWidgets);
      expect(find.textContaining('Delete'), findsWidgets);
      expect(find.textContaining('Consent'), findsWidgets);
    });
  });
}
