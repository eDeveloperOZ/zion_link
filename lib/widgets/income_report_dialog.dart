import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../models/apartment.dart'; // Added this line to import the Apartment class
import '../utils/file_storage.dart'; // Added this line to import the LocalStorage class

class ReportIncomeDialog extends StatefulWidget {
  final String apartmentId;

  const ReportIncomeDialog({Key? key, required this.apartmentId})
      : super(key: key);
  @override
  _ReportIncomeDialogState createState() => _ReportIncomeDialogState();
}

class _ReportIncomeDialogState extends State<ReportIncomeDialog> {
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedMethod;

  Widget _buildAmountTextField() {
    return TextField(
      controller: _amountController,
      decoration: InputDecoration(labelText: 'סכום'),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: Center(child: Text('בחר תאריך')),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButton<String>(
      value: _selectedMethod,
      hint: Text('בחר שיטת תשלום'),
      items: <String>['מזומן', 'צ׳ק', 'העברה בנקאית', 'הוראת קבע']
          .map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMethod = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAmountTextField(),
            SizedBox(height: 8),
            _buildDatePicker(context),
            _buildPaymentMethodDropdown(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_amountController.text.isNotEmpty &&
                    _selectedDate != null &&
                    _selectedMethod != null) {
                  final payment = Payment(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    amount: double.parse(_amountController.text),
                    date: _selectedDate!,
                    paymentMethod: _selectedMethod!,
                    isConfirmed: false,
                  );
                  // Await the readApartment call and handle possible null
                  Apartment? apartment =
                      await LocalStorage.readApartment(widget.apartmentId);
                  if (apartment != null) {
                    apartment.reportPayment(payment);
                    await LocalStorage.writeApartment(apartment);
                    Navigator.of(context).pop(true);
                  } else {
                    // Handle the case when the apartment is null
                    print("הדירה לא נמצאה.");
                  }
                }
              },
              child: Text('שלח'),
            ),
          ],
        ),
      ),
    );
  }
}
