import '../models/payment.dart';
import 'apartment_service.dart';
import 'storage_service.dart';
import '../utils/logger.dart'; // Import Logger class

class PaymentService {
  StorageService _storageService = StorageService();
  ApartmentService _apartmentService = ApartmentService();

  Future<List<Payment>> getAllPaymentsForApartment(
      String buildingId, String apartmentId) async {
    final apartmentService = ApartmentService();
    final apartments =
        await apartmentService.getAllApartmentsForBuilding(buildingId);
    final apartment =
        apartments.firstWhere((apartment) => apartment.id == apartmentId);
    return apartment.payments;
  }

  Future<Payment?> getPaymentById(String apartmentId, String paymentId) async {
    ApartmentService apartmentService = ApartmentService();
    final apartment = await apartmentService.getApartmentById(apartmentId);
    final payments = apartment?.payments;
    return payments?.firstWhere((payment) => payment.id == paymentId);
  }

  Future<void> addPaymentToApartment(
      String apartmentId, Payment payment) async {
    final apartmentService = ApartmentService();
    final storageService = StorageService();
    final apartment = await apartmentService.getApartmentById(apartmentId);
    if (apartment != null) {
      apartment.payments.add(payment);
      storageService.addPaymentToBuilding(apartment.buildingId, payment);
    } else {
      Logger.error(
          "Apartment with ID $apartmentId not found."); // Use Logger.error
    }
  }

  Future<void> updatePayment(String apartmentId, Payment updatedPayment) async {
    // Retrieve the apartment to ensure it exists
    final apartment = await _apartmentService.getApartmentById(apartmentId);
    if (apartment != null) {
      // Update the payment in the apartment's payment list
      int paymentIndex = apartment.payments
          .indexWhere((payment) => payment.id == updatedPayment.id);
      if (paymentIndex != -1) {
        apartment.payments[paymentIndex] = updatedPayment;
        // Now, use StorageService to persist the changes
        await _storageService.updatePayment(updatedPayment);
      } else {
        Logger.warning(
            "Payment with ID ${updatedPayment.id} not found in apartment $apartmentId."); // Use Logger.warning
      }
    } else {
      Logger.error(
          "Apartment with ID $apartmentId not found."); // Use Logger.error
    }
  }

  Future<void> deletePayment(String apartmentId, String paymentId) async {
    final apartmentService = ApartmentService();
    final storageService = StorageService();
    final apartment = await apartmentService.getApartmentById(apartmentId);
    if (apartment != null) {
      await storageService.deletePayment(apartment.buildingId, paymentId);
    } else {
      Logger.error(
          "Apartment with ID $apartmentId not found."); // Use Logger.error
    }
  }
}
