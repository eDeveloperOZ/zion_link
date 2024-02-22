import '../models/payment.dart';
import '../utils/file_storage.dart';

class PaymentService {
  Future<List<Payment>> fetchPayments(String buildingId) async {
    return await LocalStorage.readPayments(buildingId);
  }

  Future<void> addPayment(String buildingId, Payment newPayment) async {
    await LocalStorage.addPaymentToBuilding(buildingId, newPayment);
  }

  Future<void> updatePayment(Payment updatedPayment) async {
    await LocalStorage.updatePayment(updatedPayment);
  }

  Future<void> deletePayment(String buildingId, String paymentId) async {
    await LocalStorage.deletePayment(buildingId, paymentId);
  }
}
