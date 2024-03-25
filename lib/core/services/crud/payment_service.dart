import '../../models/payment.dart';
import '../storage_service.dart';

class PaymentService {
  Future<List<Payment>> readAllPaymentsForApartment(String apartmentId) {
    return StorageService.readAllPaymentsForApartment(apartmentId);
  }

  Future<void> createPayment(Payment newPayment) async {
    await StorageService.createPayment(newPayment);
  }

  Future<Payment?> getPaymentById(String apartmentId, String paymentId) async {
    return await StorageService.readPaymentById(paymentId);
  }

  Future<void> updatePayment(Payment updatedPayment) async {
    await StorageService.updatePayment(updatedPayment);
  }

  Future<void> deletePayment(String paymentId) async {
    await StorageService.deletePayment(paymentId);
  }
}
