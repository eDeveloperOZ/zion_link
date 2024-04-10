import 'package:flutter/material.dart';
import 'package:tachles/core/models/apartment.dart';

class ApartmentBulkAddScreen extends StatefulWidget {
  final List<Apartment> apartments;

  ApartmentBulkAddScreen({required this.apartments});

  @override
  _ApartmentBulkAddScreenState createState() => _ApartmentBulkAddScreenState();
}

class _ApartmentBulkAddScreenState extends State<ApartmentBulkAddScreen> {
  final List<Apartment> _apartments = [];
  int _numberOfApartments = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('הוסף דירות בבניין'),
        Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'מספר דירות',
                ),
                onChanged: (value) {
                  setState(() {
                    _numberOfApartments = int.tryParse(value) ?? 1;
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addApartments,
              child: Text('הוסף'),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _apartments.length,
            itemBuilder: (context, index) {
              final apartment = _apartments[index];
              return ListTile(
                title: Text('דירה ${apartment.number}'),
                subtitle: Text(
                    'בעלים: ${apartment.ownerId}, דייר: ${apartment.tenantId}'),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addApartments() {
    final newApartments = List.generate(_numberOfApartments, (index) {
      return Apartment(
        id: UniqueKey().toString(),
        buildingId: '',
        number: '${index + 1}',
        ownerId: '',
        tenantId: '',
        yearlyPaymentAmount: 0,
        pastDebt: 0,
      );
    });

    setState(() {
      _apartments.addAll(newApartments);
    });
  }
}
