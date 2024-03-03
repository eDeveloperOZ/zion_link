import 'apartment.dart';
import 'expense.dart';

class Building {
  final String id;
  String name;
  double balance;
  final String address;
  List<Apartment> apartments;
  List<Expense> expenses;

  Building(
      {required this.id,
      required this.name,
      this.balance = 0,
      required this.address,
      required this.apartments,
      required this.expenses});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'address': address,
      'apartments': apartments.map((apartment) => apartment.toJson()).toList(),
      'expenses': expenses.map((expense) => expense.toJson()).toList(),
    };
  }

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
        id: json['id'], // Deserialize id field
        name: json['name'],
        balance: json['balance']?.toDouble(),
        address: json['address'],
        apartments: (json['apartments'] as List)
            .map((apartmentJson) => Apartment.fromJson(apartmentJson))
            .toList(),
        expenses: (json['expenses'] as List)
            .map((expenseJson) => Expense.fromJson(expenseJson))
            .toList());
  }
}
