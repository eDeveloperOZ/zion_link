import 'package:tachles/core/models/payment.dart';
import 'package:tachles/core/services/supabase_service.dart';

class PaymentService {
  final SupabaseService supabaseService = SupabaseService();

  Future<List<Payment>> readAllPaymentsForApartment(String apartmentId) async {
    return await supabaseService.readAllForApartment<Payment>(apartmentId);
  }

  Future<void> createPayment(Payment newPayment) async {
    await supabaseService.create<Payment>(newPayment);
  }

  Future<Payment?> getPaymentById(String apartmentId, String paymentId) async {
    return await supabaseService.readById<Payment>(paymentId);
  }

  Future<void> updatePayment(Payment updatedPayment) async {
    await supabaseService.update<Payment>(updatedPayment);
  }

  Future<void> deletePayment(String paymentId) async {
    await supabaseService.delete<Payment>(paymentId);
  }
}
