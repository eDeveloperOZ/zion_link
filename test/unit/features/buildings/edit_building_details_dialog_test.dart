// test/unit/widgets/edit_building_details_dialog_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/features/buildings/edit_building_details_dialog.dart';

void main() {
  group('EditBuildingDetailsDialog', () {
    late Building building;
    late Function(String) onNameChanged;

    setUp(() {
      building = Building(
          id: '1',
          name: 'Building 1',
          address: '123 Test St',
          balance: 0,
          apartments: [],
          expenses: []);
      onNameChanged = (newName) {
        building = Building(
            id: building.id,
            name: newName,
            address: building.address,
            balance: building.balance,
            apartments: building.apartments,
            expenses: building.expenses);
      };
    });

    testWidgets('displays building name in text field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditBuildingDetailsDialog(
              building: building,
              onNameChanged: onNameChanged,
            ),
          ),
        ),
      );

      expect(find.text('Building 1'), findsOneWidget);
    });

    testWidgets('updates building name when text field changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditBuildingDetailsDialog(
              building: building,
              onNameChanged: onNameChanged,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'New Building Name');
      await tester.tap(find.text('שמור'));
      await tester.pumpAndSettle();

      expect(building.name, 'New Building Name');
    });

    testWidgets('displays "עריכת פרטי בניין" text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditBuildingDetailsDialog(
              building: building,
              onNameChanged: onNameChanged,
            ),
          ),
        ),
      );

      expect(find.text('עריכת פרטי בניין'), findsOneWidget);
    });
  });
}
