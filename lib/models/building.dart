import 'apartment.dart';
import 'expense.dart';

class Building {
  final String id;
  String name;
  final String address;
  List<Apartment> apartments;
  List<Expense> expenses;

  Building(
      {required this.id,
      required this.name,
      required this.address,
      required this.apartments,
      required this.expenses});

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Serialize id field
      'name': name,
      'address': address,
      'apartments': apartments.map((apartment) => apartment.toJson()).toList(),
      'expenses': expenses.map((expense) => expense.toJson()).toList(),
    };
  }

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
        id: json['id'], // Deserialize id field
        name: json['name'],
        address: json['address'],
        apartments: (json['apartments'] as List)
            .map((apartmentJson) => Apartment.fromJson(apartmentJson))
            .toList(),
        expenses: (json['expenses'] as List)
            .map((expenseJson) => Expense.fromJson(expenseJson))
            .toList());
  }
}
