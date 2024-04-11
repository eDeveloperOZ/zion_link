class Expense {
  final String id;
  final String buildingId; // foreign key
  final String serviceProviderId; // foreign key
  final bool isUtility; // new field
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? filePath;

  Expense({
    required this.id,
    required this.buildingId,
    required this.serviceProviderId,
    required this.isUtility,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.filePath,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      buildingId: json['buildingId'],
      serviceProviderId: json['serviceProviderId'],
      isUtility: json['isUtility'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      categoryId: json['categoryId'],
      filePath: json['filePath'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'buildingId': buildingId,
      'serviceProviderId': serviceProviderId,
      'isUtility': isUtility,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'filePath': filePath,
    };

    if (filePath != null) {
      data['filePath'] = filePath as Object; // Cast filePath to Object
    }

    return data;
  }

  Expense copyWith({
    String? id,
    String? buildingId,
    String? serviceProviderId,
    bool? isUtility,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? filePath,
  }) {
    return Expense(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      serviceProviderId: serviceProviderId ?? this.serviceProviderId,
      isUtility: isUtility ?? this.isUtility,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      filePath: filePath ?? this.filePath,
    );
  }
}
