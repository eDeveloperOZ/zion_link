class Apartment {
  final String id;
  final String buildingId;
  final String number;
  final String ownerId;
  String tenantId;
  double yearlyPaymentAmount;
  double pastDebt = 0;

  Apartment({
    required this.id,
    required this.buildingId,
    required this.number,
    required this.ownerId,
    required this.tenantId,
    required this.yearlyPaymentAmount,
    required this.pastDebt,
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
      'number': number,
      'ownerName': ownerId,
      'tenantName': tenantId,
      'yearlyPaymentAmount': yearlyPaymentAmount,
      'pastDebt': pastDebt,
    };
  }

  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['id'],
      buildingId: json['buildingId'],
      number: json['number'],
      ownerId: json['ownerName'],
      tenantId: json['tenantName'] ?? '',
      yearlyPaymentAmount: json['yearlyPaymentAmount'],
      pastDebt: json['pastDebt'] ?? 0,
    );
  }
}
