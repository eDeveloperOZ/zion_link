class Apartment {
  final String id;
  final String buildingId;
  final String number;
  final String ownerName;
  String attendantName;
  double yearlyPaymentAmount;
  double pastDebt = 0;

  Apartment({
    required this.id,
    required this.buildingId,
    required this.number,
    required this.ownerName,
    required this.attendantName,
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
      'ownerName': ownerName,
      'attendantName': attendantName,
      'yearlyPaymentAmount': yearlyPaymentAmount,
      'pastDebt': pastDebt,
    };
  }

  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['id'],
      buildingId: json['buildingId'],
      number: json['number'],
      ownerName: json['ownerName'],
      attendantName: json['attendantName'] ?? '',
      yearlyPaymentAmount: json['yearlyPaymentAmount'],
      pastDebt: json['pastDebt'] ?? 0,
    );
  }
}
