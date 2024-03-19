import 'package:flutter_test/flutter_test.dart';
import 'package:zion_link/core/models/apartment.dart';

void main() {
  group('Apartment', () {
    test('should have a valid structure', () {
      final apartment = Apartment(
        id: '1',
        buildingId: '1',
        number: '1',
        ownerName: 'owner',
        attendantName: 'attendant',
        yearlyPaymentAmount: 1000,
        payments: [],
      );

      expect(apartment.id, '1');
      expect(apartment.buildingId, '1');
      expect(apartment.number, '1');
      expect(apartment.ownerName, 'owner');
      expect(apartment.attendantName, 'attendant');
      expect(apartment.yearlyPaymentAmount, 1000);
      expect(apartment.payments, []);
    });
  });
}
