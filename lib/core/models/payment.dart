class Payment {
  final String id;
  final String apartmentId; // foreign key
  final String madeByName;
  final double amount;
  final DateTime dateMade;
  final String periodCoverageStart;
  final String periodCoverageEnd;
  final String paymentMethod;
  String reason = '';
  bool isConfirmed = false;

  Payment({
    required this.id,
    required this.apartmentId,
    required this.madeByName,
    required this.amount,
    required this.dateMade,
    required this.periodCoverageStart,
    required this.periodCoverageEnd,
    required this.paymentMethod,
    required this.reason,
    required this.isConfirmed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartmentId': apartmentId,
      'madeByName': madeByName,
      'amount': amount,
      'dateMade': dateMade.toIso8601String(),
      'periodCoverageStart': periodCoverageStart,
      'periodCoverageEnd': periodCoverageEnd,
      'paymentMethod': paymentMethod,
      'reason': reason,
      'isConfirmed': isConfirmed,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      apartmentId: json['apartmentId'],
      madeByName: json['madeByName'],
      amount: json['amount'],
      dateMade: DateTime.parse(json['dateMade']),
      periodCoverageStart: json['periodCoverageStart'],
      periodCoverageEnd: json['periodCoverageEnd'],
      paymentMethod: json['paymentMethod'],
      reason: json['reason'],
      isConfirmed: json['isConfirmed'] ?? false,
    );
  }
}
