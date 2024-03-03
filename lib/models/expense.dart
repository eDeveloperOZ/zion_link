class Expense {
  final String id;
  final String buildingId;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? filePath;

  Expense({
    required this.id,
    required this.buildingId,
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
      title: json['title'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      categoryId: json['categoryId'],
      filePath: json['filePath'], // Parse filePath from JSON
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'buildingId': buildingId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
    };

    if (filePath != null) {
      data['filePath'] = filePath as Object; // Cast filePath to Object
    }

    return data;
  }

  Expense copyWith({
    String? id,
    String? buildingId,
    String? title,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? filePath,
  }) {
    return Expense(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      filePath: filePath ?? this.filePath,
    );
  }
}
