import 'package:flutter_test/flutter_test.dart';
import 'package:zion_link/core/models/building.dart';

void main() {
  group('Building', () {
    test('should have a valid structure', () {
      final building = Building(
        id: '1',
        name: 'name',
        address: 'address',
        apartments: [],
        expenses: [],
      );

      expect(building.id, '1');
      expect(building.name, 'name');
      expect(building.address, 'address');
      expect(building.apartments, []);
      expect(building.expenses, []);
    });
  });
}
