import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/features/apartments/add_apartment_dialog.dart';

void main() {
  group('AddApartmentDialog', () {
    // Add your test cases here
    testWidgets('should have a valid structure', (WidgetTester tester) async {
      final addApartmentDialog = EditApartmentDetails(
        onAdd: (Apartment apartment) {},
        buildingId: '1',
      );

      await tester.pumpWidget(MaterialApp(home: addApartmentDialog));
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.text('הוסף דירה חדשה'), findsOneWidget);
    });

    // New test case to check if the dialog opens and can be interacted with
    testWidgets('should open dialog and add an apartment',
        (WidgetTester tester) async {
      Apartment? addedApartment;

      await tester.pumpWidget(MaterialApp(
        home: EditApartmentDetails(
          onAdd: (Apartment apartment) {
            addedApartment = apartment;
          },
          buildingId: '1',
        ),
      ));

      // Tap the add button to open the dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle(); // Wait for the dialog to open

      // Fill in the form
      await tester.enterText(find.bySemanticsLabel('שם הדייר'), 'John Doe');
      await tester.enterText(find.bySemanticsLabel('סכום תשלום שנתי'), '1200');

      // Tap the add button in the dialog
      await tester.tap(find.text('הוסף'));
      await tester.pumpAndSettle(); // Wait for the dialog to close

      // Check if the apartment was added
      expect(addedApartment, isNotNull);
      expect(addedApartment!.tenantId, 'John Doe');
      expect(addedApartment!.yearlyPaymentAmount, 1200);
    });
  });
}
