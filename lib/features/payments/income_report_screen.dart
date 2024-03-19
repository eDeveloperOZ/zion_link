import 'package:flutter/material.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:intl/intl.dart';
import 'package:zion_link/core/models/payment.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';
import 'package:zion_link/shared/widgets/success_message_widget.dart'; // Add this line

class IncomeReportScreen extends StatefulWidget {
  final Apartment apartment;
  final Function(Apartment) onPaymentReported;

  const IncomeReportScreen(
      {Key? key, required this.apartment, required this.onPaymentReported})
      : super(key: key);

  @override
  _IncomeReportScreenState createState() => _IncomeReportScreenState();
}

class _IncomeReportScreenState extends State<IncomeReportScreen> {
  late String payerName;
  late double basePaymentAmount;
  late double paymentAmount;
  int numberOfPayments = 1;
  String paymentMethod = 'מזומן';
  DateTime paymentDate = DateTime.now();
  DateTime paymentPeriodStart = DateTime.now();
  DateTime paymentPeriodEnd = DateTime.now().add(Duration(days: 30));
  String notes = '';
  bool isForCommittee = true;
  String paymentPurpose = '';
  final TextEditingController _paymentPurposeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    payerName = widget.apartment.attendantName; // Default to owner's name
    basePaymentAmount = widget.apartment.yearlyPaymentAmount / 12;
    paymentAmount = basePaymentAmount; // Initialize with base amount
    _paymentPurposeController.text = paymentPurpose;
  }

  @override
  void dispose() {
    _paymentPurposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('דיווח תשלום'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('מספר דירה: ${widget.apartment.number}'),
            SizedBox(height: 16),
            _buildPayerRadioButtons(),
            if (payerName == 'אחר') _buildPayerNameTextField(),
            _buildCommitteeCheckbox(),
            if (!isForCommittee) _buildPaymentPurposeField(),
            _buildPaymentAmountField(),
            if (isForCommittee) _buildNumberOfPaymentsDropdown(),
            _buildPaymentMethodDropdown(),
            _buildDatePicker('תאריך תשלום:', paymentDate, (date) {
              setState(() => paymentDate = date);
            }),
            if (isForCommittee)
              _buildDatePicker('תקופת התשלום מ:', paymentPeriodStart, (date) {
                setState(() => paymentPeriodStart = date);
              }),
            if (isForCommittee)
              _buildDatePicker('תקופת התשלום עד:', paymentPeriodEnd, (date) {
                setState(() => paymentPeriodEnd = date);
              }),
            _buildNotesTextField(),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitReport,
              child: Text('שלח דיווח'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayerRadioButtons() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text('המשכיר (${widget.apartment.attendantName})'),
          value: widget.apartment.attendantName,
          groupValue: payerName,
          onChanged: (value) {
            setState(() => payerName = value!);
          },
        ),
        RadioListTile<String>(
          title: Text('הבעלים (${widget.apartment.ownerName})'),
          value: widget.apartment.ownerName,
          groupValue: payerName,
          onChanged: (value) {
            setState(() => payerName = value!);
          },
        ),
        RadioListTile<String>(
          title: Text('אחר'),
          value: 'אחר',
          groupValue: payerName,
          onChanged: (value) {
            setState(() => payerName = value!);
          },
        ),
      ],
    );
  }

  Widget _buildPayerNameTextField() {
    return TextField(
      decoration: InputDecoration(labelText: 'שם המשלם'),
      onChanged: (value) => setState(() => payerName = value),
    );
  }

  Widget _buildCommitteeCheckbox() {
    return CheckboxListTile(
      title: Text('עבור וועד בית'),
      value: isForCommittee,
      onChanged: (bool? value) {
        setState(() {
          isForCommittee = value!;
          if (!isForCommittee) {
            paymentPurpose = "";
            paymentAmount = 0;
          } else {
            // Reset to default behavior for committee payments
            paymentAmount = basePaymentAmount * numberOfPayments;
          }
        });
      },
    );
  }

  Widget _buildPaymentPurposeField() {
    return TextField(
      controller: _paymentPurposeController,
      decoration: InputDecoration(labelText: 'מטרת התשלום'),
      onChanged: (value) => setState(() {
        paymentPurpose = value;
      }),
    );
  }

  Widget _buildPaymentAmountField() {
    return TextField(
      controller: TextEditingController(text: paymentAmount.toStringAsFixed(2)),
      decoration: InputDecoration(labelText: 'סכום'),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        double parsedValue = double.tryParse(value) ?? 0;
        setState(() {
          if (isForCommittee) {
            basePaymentAmount = parsedValue;
            paymentAmount = basePaymentAmount * numberOfPayments;
          } else {
            paymentAmount =
                parsedValue; // Allow manual entry of payment amount when not for committee
          }
        });
      },
    );
  }

  Widget _buildNumberOfPaymentsDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<int>(
          value: numberOfPayments,
          onChanged: (int? newValue) {
            setState(() {
              numberOfPayments = newValue!;
              paymentAmount = basePaymentAmount *
                  numberOfPayments; // Multiply the base amount
              if (numberOfPayments > 1) {
                paymentPeriodEnd = DateTime(
                    paymentPeriodEnd.year,
                    paymentPeriodStart.month + numberOfPayments - 1,
                    paymentPeriodEnd.day);
              } else {
                paymentPeriodEnd = DateTime(paymentPeriodStart.year,
                    paymentPeriodStart.month + 1, paymentPeriodStart.day);
              }
            });
          },
          items: List.generate(12, (index) => index + 1)
              .map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(value.toString()),
            );
          }).toList(),
        ),
        Text('מס׳ תשלומים'),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButton<String>(
      value: paymentMethod,
      onChanged: (String? newValue) {
        setState(() {
          paymentMethod = newValue!;
        });
      },
      items: <String>['מזומן', 'צ׳ק', 'העברה בנקאית', 'הוראת קבע']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(
      String label, DateTime initialDate, Function(DateTime) onDateChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        TextButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
            );
            if (picked != null && picked != initialDate) {
              onDateChanged(picked);
            }
          },
          child: Text(DateFormat('dd/MM/yyyy').format(initialDate)),
        ),
      ],
    );
  }

  Widget _buildNotesTextField() {
    return TextField(
      decoration: InputDecoration(labelText: 'הערות'),
      onChanged: (value) => setState(() => notes = value),
    );
  }

  void _submitReport() async {
    ApartmentService apartmentService = ApartmentService();

    List<Payment> payments = [];

    for (int i = 0; i < numberOfPayments; i++) {
      int startMonth = paymentPeriodStart.month + i;
      int startYear = paymentPeriodStart.year;
      if (startMonth > 12) {
        startYear += startMonth ~/ 12;
        startMonth = startMonth % 12;
      }

      int endMonth = paymentPeriodEnd.month + i + 1;
      int endYear = paymentPeriodEnd.year;
      if (endMonth > 12) {
        endYear += endMonth ~/ 12;
        endMonth = endMonth % 12;
      }

      // Create a new Payment object for each payment
      Payment payment = Payment(
        id: UniqueKey().toString(), // Generate a unique ID for each payment
        apartmentId: widget.apartment.id,
        madeByName: payerName,
        amount: paymentAmount / numberOfPayments,
        dateMade: paymentDate,
        periodCoverageStart:
            DateTime(startYear, startMonth, paymentPeriodStart.day)
                .toIso8601String(),
        periodCoverageEnd:
            DateTime(endYear, endMonth, paymentPeriodEnd.day).toIso8601String(),
        paymentMethod: paymentMethod,
        reason: paymentPurpose,
        isConfirmed: false,
      );

      payments.add(payment);
    }

    widget.apartment.payments.addAll(payments);
    apartmentService.updateApartment(widget.apartment);
    ScaffoldMessenger.of(context).showSnackBar(
      SuccessMessageWidget.create(message: 'הדיווח נשלח בהצלחה'),
    );
    widget.onPaymentReported(widget.apartment);
    if (Navigator.canPop(context)) Navigator.of(context).pop();
  }
}
