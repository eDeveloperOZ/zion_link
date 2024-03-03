import 'payment.dart'; // Importing the Payment class

class Apartment {
  final String id;
  final String buildingId;
  String attendantName;
  double yearlyPaymentAmount;
  List<Payment> payments;

  Apartment({
    required this.id,
    required this.buildingId,
    required this.attendantName,
    required this.yearlyPaymentAmount,
    required this.payments,
  });

  // void reportPayment(Payment payment) {
  //   payments.add(payment);
  // }

  // double getAmountLeft() {
  //   double totalPaid = payments.fold(0, (sum, item) => sum + item.amount);
  //   return yearlyPaymentAmount - totalPaid;
  // }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buildingId': buildingId,
      'attendantName': attendantName,
      'yearlyPaymentAmount': yearlyPaymentAmount,
      'payments': payments
          .map((payment) => payment.toJson())
          .toList(), // Convert payments to JSON
    };
  }

  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['id'],
      buildingId: json['buildingId'],
      attendantName: json['attendantName'],
      yearlyPaymentAmount: json['yearlyPaymentAmount'],
      payments: json['payments'] != null
          ? (json['payments'] as List)
              .map((paymentJson) => Payment.fromJson(paymentJson))
              .toList()
          : [], // Handle no payments case by providing an empty list
    );
  }
}
