import 'package:zion_link/models/building.dart';
import '../models/payment.dart';
import 'apartment_service.dart';
import 'building_service.dart';
import 'storage_service.dart';
import '../models/apartment.dart';

class PaymentService {
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
    apartment?.payments.add(payment);
    storageService.addPaymentToBuilding(apartment!.buildingId, payment);
  }

  Future<void> updatePayment(String apartmentId, Payment updatedPayment) async {
    final apartmentService = ApartmentService();
    final apartment = await apartmentService.getApartmentById(apartmentId);
    apartment?.payments = apartment.payments
        .map((payment) =>
            payment.id == updatedPayment.id ? updatedPayment : payment)
        .toList();
  }

  Future<void> deletePayment(String apartmentId, String paymentId) async {
    final apartmentService = ApartmentService();
    final apartment = await apartmentService.getApartmentById(apartmentId);
    apartment?.payments.removeWhere((payment) => payment.id == paymentId);
  }
}
