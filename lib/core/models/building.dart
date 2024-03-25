class Building {
  final String id;
  String name;
  double balance;
  final String address;

  Building({
    required this.id,
    required this.name,
    this.balance = 0,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'address': address,
    };
  }

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
        id: json['id'], // Deserialize id field
        name: json['name'],
        balance: json['balance']?.toDouble(),
        address: json['address']);
  }
}
