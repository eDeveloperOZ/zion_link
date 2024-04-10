import 'package:flutter_test/flutter_test.dart';
import 'package:tachles/core/models/expense.dart';

void main() {
  group('Expense', () {
    test('should have a valid structure', () {
      final expense = Expense(
        id: '1',
        buildingId: '1',
        title: 'title',
        amount: 100,
        date: DateTime.now(),
        categoryId: '1',
        filePath: 'path',
      );

      expect(expense.id, '1');
      expect(expense.buildingId, '1');
      expect(expense.title, 'title');
      expect(expense.amount, 100);
      expect(expense.date, DateTime.now());
      expect(expense.categoryId, '1');
      expect(expense.filePath, 'path');
    });
  });
}
