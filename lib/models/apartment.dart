import 'payment.dart'; // Importing the Payment class

class Apartment {
  final String id;
  String attendantName;
  double yearlyPaymentAmount;
  final List<Payment> payments; // Added to hold list of payments

  Apartment({
    required this.id,
    required this.attendantName,
    required this.yearlyPaymentAmount,
    required this.payments, // Now required and corrected syntax
  });

  void reportPayment(Payment payment) {
    payments.add(payment); // Logic to add a payment to the list
  }

  double getAmountLeft() {
    double totalPaid = payments.fold(
        0, (sum, item) => sum + item.amount); // Calculate total paid
    return yearlyPaymentAmount - totalPaid; // Return how much is left to pay
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
