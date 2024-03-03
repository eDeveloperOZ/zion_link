class Payment {
  final String id;
  final String apartmentId;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  bool isConfirmed = false;

  Payment({
    required this.id,
    required this.apartmentId,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.isConfirmed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartmentId': apartmentId,
      'amount': amount,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'isConfirmed': isConfirmed,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      apartmentId: json['apartmentId'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      paymentMethod: json['paymentMethod'],
      isConfirmed: json['isConfirmed'] ?? false,
    );
  }
}
