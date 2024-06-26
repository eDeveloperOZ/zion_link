import 'package:flutter_test/flutter_test.dart';
import 'package:tachles/core/models/apartment.dart';

void main() {
  group('Apartment', () {
    test('should have a valid structure', () {
      final apartment = Apartment(
        id: '1',
        buildingId: '1',
        number: '1',
        ownerId: 'owner',
        tenantId: 'attendant',
        yearlyPaymentAmount: 1000,
        payments: [],
      );

      expect(apartment.id, '1');
      expect(apartment.buildingId, '1');
      expect(apartment.number, '1');
      expect(apartment.ownerId, 'owner');
      expect(apartment.tenantId, 'attendant');
      expect(apartment.yearlyPaymentAmount, 1000);
      expect(apartment.payments, []);
    });
  });
}
