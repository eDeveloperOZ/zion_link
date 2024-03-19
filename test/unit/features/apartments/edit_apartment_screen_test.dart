import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';
import 'package:zion_link/features/apartments/edit_apartment_screen.dart';

class MockApartmentService extends Mock implements ApartmentService {}

void main() {
  late MockApartmentService mockApartmentService;
  late Apartment testApartment;

  setUp(() {
    mockApartmentService = MockApartmentService();
    testApartment = Apartment(
      id: '1',
      buildingId: '1',
      number: '101',
      ownerName: 'John Doe',
      attendantName: 'Jane Doe',
      yearlyPaymentAmount: 1200.00,
      payments: [],
    );
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Provider<ApartmentService>(
        create: (_) => mockApartmentService,
        child: child,
      ),
    );
  }

  testWidgets('EditApartmentScreen displays the correct initial values',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(EditApartmentScreen(
        apartment: testApartment, onApartmentUpdated: (_) {})));

    expect(find.text('101'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('1200.0'), findsOneWidget);
  });

  testWidgets('EditApartmentScreen updates apartment on save',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(EditApartmentScreen(
        apartment: testApartment, onApartmentUpdated: (_) {})));

    // Simulate user input
    await tester.enterText(find.byType(TextFormField).at(0), 'New Owner');
    await tester.enterText(find.byType(TextFormField).at(1), 'New Attendant');
    await tester.enterText(find.byType(TextFormField).at(2), '1400');

    // Simulate form submission
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify that the apartment service was called to update the apartment
    verify(mockApartmentService.updateApartment(testApartment)).called(1);
  });
}
