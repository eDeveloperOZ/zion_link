class Apartment {
  final String id;
  final String buildingId;
  final String number;
  String ownerId;
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buildingId': buildingId,
      'number': number,
      'ownerId': ownerId,
      'tenantId': tenantId,
      'yearlyPaymentAmount': yearlyPaymentAmount,
      'pastDebt': pastDebt,
    };
  }

  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['id'],
      buildingId: json['buildingId'],
      number: json['number'],
      ownerId: json['ownerId'],
      tenantId: json['tenantId'] ?? '',
      yearlyPaymentAmount: (json['yearlyPaymentAmount'] is int)
          ? (json['yearlyPaymentAmount'] as int).toDouble()
          : json['yearlyPaymentAmount'],
      pastDebt: (json['pastDebt'] is int)
          ? (json['pastDebt'] as int).toDouble()
          : json['pastDebt'] ?? 0.0,
    );
  }
}
