import 'package:flutter/material.dart';
import 'package:zion_link/services/apartment_service.dart';
import '../models/payment.dart';
import '../models/apartment.dart';
import '../services/payment_service.dart';

class IncomeReportDialog extends StatefulWidget {
  final String apartmentId;

  const IncomeReportDialog({Key? key, required this.apartmentId})
      : super(key: key);
  @override
  _ReportIncomeDialogState createState() => _ReportIncomeDialogState();
}

class _ReportIncomeDialogState extends State<IncomeReportDialog> {
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedMethod;
  int _numberOfpayments = 1;

  void _handlePaymntMethod() {
    if (_selectedMethod == 'צ׳ק') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('כמות הצ׳קים'),
            content: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'הזן את מספר הצ׳קים'),
              onChanged: (String value) {
                int numberOfChecks = int.tryParse(value) ?? 0;
                if (numberOfChecks < 1) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('שגיאה'),
                        content: Text('זהו לא ערך תקין, אנא הזן מספר גדול מ-0'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('אישור'),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Close the error dialog
                              Navigator.of(context)
                                  .pop(); // Close the number input dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
                setState(() {
                  _numberOfpayments = numberOfChecks;
                });
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text('אישור'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (_selectedMethod == 'העברה בנקאית' ||
        _selectedMethod == 'הוראת קבע') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('חידוש אוטומטי'),
            content: Text('האם לחדש את התשלום אוטומטית?'),
            actions: <Widget>[
              TextButton(
                child: Text('כן'),
                onPressed: () {
                  _numberOfpayments = 12;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('לא'),
                onPressed: () {
                  _numberOfpayments = 1;
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Text('דיווח תשלום')),
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
                  ApartmentService apartmentService = ApartmentService();
                  Apartment? apartment = await apartmentService
                      .getApartmentById(widget.apartmentId);
                  if (apartment != null) {
                    for (int i = 0; i < _numberOfpayments; i++) {
                      final payment = Payment(
                        id: DateTime.now()
                            .add(Duration(days: i))
                            .millisecondsSinceEpoch
                            .toString(),
                        apartmentId: apartment.id,
                        amount: double.parse(_amountController.text),
                        date: DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month + i,
                            _selectedDate!.day), // Increment month by i
                        paymentMethod: _selectedMethod!,
                        isConfirmed: false,
                      );
                      PaymentService paymentService = PaymentService();
                      await paymentService.addPaymentToApartment(
                          payment.apartmentId, payment);
                    }
                    Navigator.of(context).pop(true);
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('שגיאה'),
                          content: Text('הדירה לא נמצאה'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('אישור'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
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
          _handlePaymntMethod();
        });
      },
    );
  }
}
