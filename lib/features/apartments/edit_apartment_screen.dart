import 'package:flutter/material.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';

class EditApartmentScreen extends StatefulWidget {
  final Apartment apartment;
  final Function(Apartment) onApartmentUpdated; // Add this line

  const EditApartmentScreen({
    Key? key,
    required this.apartment,
    required this.onApartmentUpdated, // Modify this line
  }) : super(key: key);

  @override
  _EditApartmentScreenState createState() => _EditApartmentScreenState();
}

class _EditApartmentScreenState extends State<EditApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late String number;
  late String ownerName;
  late String tenantName;
  late double yearlyPaymentAmount;

  @override
  void initState() {
    super.initState();
    number = widget.apartment.number;
    ownerName = widget.apartment.ownerId;
    tenantName = widget.apartment.tenantId;
    yearlyPaymentAmount = widget.apartment.yearlyPaymentAmount;
  }

  void _saveApartment() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Apartment updatedApartment = Apartment(
        id: widget.apartment.id,
        buildingId: widget.apartment.buildingId,
        number: number,
        ownerId: ownerName,
        tenantId: tenantName,
        yearlyPaymentAmount: yearlyPaymentAmount,
        pastDebt: widget.apartment.pastDebt,
      );
      ApartmentService().updateApartment(updatedApartment);
      widget.onApartmentUpdated(updatedApartment);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('עריכת דירה'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'מספר דירה: $number',
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextFormField(
              initialValue: ownerName,
              decoration: InputDecoration(
                  labelText: 'שם הבעלים'), // Owner Name in Hebrew
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'אנא הזן את שם הבעלים';
                }
                return null;
              },
              onSaved: (value) => ownerName = value!,
            ),
            TextFormField(
              initialValue: tenantName,
              decoration: InputDecoration(
                  labelText: 'שם המשכיר'), // Attendant Name in Hebrew
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'אנא הזן את שם המשכיר'; // Please enter the attendant's name in Hebrew
                }
                return null;
              },
              onSaved: (value) => tenantName = value!,
            ),
            TextFormField(
              initialValue: '',
              decoration: InputDecoration(
                labelText: 'סכום התשלום השנתי',
                hintText: '0.0',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    double.tryParse(value) == null) {
                  return 'אנא הזן סכום תקף';
                }
                return null;
              },
              onSaved: (value) => yearlyPaymentAmount = double.parse(value!),
            ),
            ElevatedButton(
              onPressed: _saveApartment,
              child: Text('שמור שינויים'),
            ),
          ],
        ),
      ),
    );
  }
}
