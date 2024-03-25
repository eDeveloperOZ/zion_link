import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/services/crud/building_service.dart';
import 'package:zion_link/features/buildings/add_building_view.dart';

class MockBuildingService extends Mock implements BuildingService {}

void main() {
  group('AddBuildingView Tests', () {
    late MockBuildingService mockBuildingService;
    late Function addBuildingCallback;
    late Building testBuilding; // Declare testBuilding as late

    setUp(() {
      mockBuildingService = MockBuildingService();
      addBuildingCallback = (_) {};
      testBuilding = Building(
          id: '1',
          name: 'Test Building',
          address: '123 Test St',
          balance: 0,
          apartments: [],
          expenses: []); // Initialize testBuilding here
      // Mock the BuildingService methods used in AddBuildingView
      when(mockBuildingService.createBuilding(testBuilding))
          .thenAnswer((_) async => Future.value());
      when(mockBuildingService.updateBuilding(testBuilding))
          .thenAnswer((_) async => Future.value());
    });

    Widget makeTestableWidget() {
      return MaterialApp(
        home: AddBuildingView(addBuildingCallback: addBuildingCallback),
      );
    }

    testWidgets('Can enter text into fields and submit form',
        (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Find TextFields and Button
      final nameField = find.byType(TextField).at(0);
      final addressField = find.byType(TextField).at(1);
      final numberOfApartmentsField = find.byType(TextField).at(2);
      final addButton = find.byType(ElevatedButton);

      // Enter text into the TextFields
      await tester.enterText(nameField, 'Test Building');
      await tester.enterText(addressField, '123 Test St');
      await tester.enterText(numberOfApartmentsField, '10');

      // Tap the add button
      await tester.tap(addButton);
      await tester.pump();

      // Verify that BuildingService methods were called
      verify(mockBuildingService.createBuilding(testBuilding)).called(1);
      verify(mockBuildingService.updateBuilding(testBuilding)).called(1);
    });
  });
}
