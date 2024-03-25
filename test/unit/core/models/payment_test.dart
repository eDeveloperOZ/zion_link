import 'package:flutter_test/flutter_test.dart';
import 'package:zion_link/core/models/payment.dart';

void main() {
  group('Payment', () {
    // Add your test cases here
    test('should have a valid structure', () {
      final payment = Payment(
        id: '1',
        apartmentId: '1',
        madeByName: 'name',
        amount: 100,
        dateMade: DateTime.now(),
        periodCoverageStart: DateTime.now().toString(),
        periodCoverageEnd: DateTime.now().toString(),
        paymentMethod: 'method',
        reason: 'reason',
        isConfirmed: false,
      );

      expect(payment.id, '1');
      expect(payment.apartmentId, '1');
      expect(payment.madeByName, 'name');
      expect(payment.amount, 100);
      expect(payment.dateMade, isA<DateTime>());
      expect(payment.periodCoverageStart, isA<DateTime>());
      expect(payment.periodCoverageEnd, isA<DateTime>());
      expect(payment.paymentMethod, 'method');
      expect(payment.reason, 'reason');
      expect(payment.isConfirmed, isFalse);
    });
  });
}
