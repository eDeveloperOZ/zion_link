import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:tachles/core/models/apartment.dart';
import 'package:intl/intl.dart';
import 'package:tachles/core/models/payment.dart';
import 'package:tachles/core/models/user.dart';
import 'package:tachles/core/services/crud/apartment_service.dart';
import 'package:tachles/core/services/crud/payment_service.dart';
import 'package:tachles/core/services/crud/user_service.dart';
import 'package:tachles/shared/widgets/error_message_widget.dart';
import 'package:tachles/shared/widgets/success_message_widget.dart';

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
  final UserService _userService = UserService();
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
  Future<User?>? tenant;
  Future<User?>? owner;
  bool sendReceiptToTenant = true;
  bool sendReceiptToOwner = false;

  @override
  void initState() {
    super.initState();
    payerName = widget.apartment.tenantId;
    basePaymentAmount = widget.apartment.yearlyPaymentAmount / 12;
    paymentAmount = basePaymentAmount;
    _paymentPurposeController.text = paymentPurpose;
    tenant = _userService.getUserById(widget.apartment.tenantId);
    owner = _userService.getUserById(widget.apartment.ownerId);
  }

  void _askForYearlyPaymentAmount() async {
    // Show a dialog to ask for the yearly payment amount
    double? newYearlyPaymentAmount = await showDialog<double>(
      context: context,
      builder: (context) {
        double? inputAmount;
        return AlertDialog(
          title: Text('הכנס סכום שנתי לתשלום'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              inputAmount = double.tryParse(value);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('אישור'),
              onPressed: () {
                Navigator.of(context).pop(inputAmount);
              },
            ),
          ],
        );
      },
    );

    // Update the yearlyPaymentAmount in the database
    if (newYearlyPaymentAmount != null) {
      widget.apartment.yearlyPaymentAmount = newYearlyPaymentAmount;
      await ApartmentService().updateApartment(widget.apartment);
      setState(() {
        basePaymentAmount = newYearlyPaymentAmount / 12;
        paymentAmount = basePaymentAmount;
      });
    }
  }

  @override
  void dispose() {
    _paymentPurposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.apartment.yearlyPaymentAmount == 0) {
        _askForYearlyPaymentAmount();
      }
    });
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
    return FutureBuilder<List<User?>>(
      future: Future.wait([tenant!, owner!]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              RadioListTile<String>(
                title: Row(
                  children: [
                    Text(
                      'המשכיר (${snapshot.data?[0]?.firstName ?? ''} ${snapshot.data?[0]?.lastName ?? ''})',
                    ),
                    Text('קבלה'),
                    Checkbox(
                      value: sendReceiptToTenant,
                      onChanged: (bool? value) {
                        setState(() {
                          sendReceiptToTenant = value!;
                        });
                      },
                    ),
                  ],
                ),
                value: widget.apartment.tenantId,
                groupValue: payerName,
                onChanged: (value) {
                  setState(() => payerName = value!);
                },
              ),
              RadioListTile<String>(
                title: Row(
                  children: [
                    Text(
                      'הבעלים (${snapshot.data?[1]?.firstName ?? ''} ${snapshot.data?[1]?.lastName ?? ''})',
                    ),
                    Text('קבלה'),
                    Checkbox(
                        value: sendReceiptToOwner,
                        onChanged: (bool? value) {
                          setState(() {
                            sendReceiptToOwner = value!;
                          });
                        }),
                  ],
                ),
                value: widget.apartment.ownerId,
                groupValue: payerName,
                onChanged: (value) {
                  setState(() => payerName = value!);
                },
              ),
            ],
          );
        } else {
          return CircularProgressIndicator(); // or any other loading indicator
        }
      },
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
    PaymentService paymentService =
        PaymentService(); // Initialize PaymentService

    List<Payment> payments = [];
    List<Payment> paymentsMade =
        await paymentService.readAllPaymentsForApartment(widget.apartment.id);

    for (int i = 0; i < numberOfPayments; i++) {
      int startMonth = paymentPeriodStart.month + i;
      int startYear = paymentPeriodStart.year;
      if (startMonth > 12) {
        startYear += startMonth ~/ 12;
        startMonth = startMonth % 12;
      }

      DateTime periodStart =
          DateTime(startYear, startMonth, paymentPeriodStart.day);
      DateTime periodEnd =
          DateTime(periodStart.year, periodStart.month + 1, periodStart.day);

      // Adjust for cases where adding a month goes beyond the last month of the year
      if (periodEnd.month > 12) {
        periodEnd = DateTime(periodEnd.year + 1, 1, periodEnd.day);
      }

      // Check if a payment already exists for the current period
      bool paymentExists = paymentsMade.any((payment) {
        DateTime existingPeriodStart =
            DateTime.parse(payment.periodCoverageStart);
        DateTime existingPeriodEnd = DateTime.parse(payment.periodCoverageEnd);
        return existingPeriodStart == periodStart &&
            existingPeriodEnd == periodEnd;
      });

      if (paymentExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorMessageWidget.create(
              message: 'תשלום כבר דווח עבור התקופה הנוכחית'),
        );
        return;
      }
      // Create a new Payment object for each payment
      Payment payment = Payment(
        id: UniqueKey().toString(),
        apartmentId: widget.apartment.id,
        madeByName: payerName,
        amount: paymentAmount / numberOfPayments,
        dateMade: paymentDate,
        periodCoverageStart: periodStart.toIso8601String(),
        periodCoverageEnd: periodEnd.toIso8601String(),
        paymentMethod: paymentMethod,
        reason: paymentPurpose,
        isConfirmed: false,
      );

      payments.add(payment);

      // Use PaymentService to create the payment
      try {
        await paymentService.createPayment(payment);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorMessageWidget.create(message: 'שגיאה בשמירת התשלום'),
        );
        return;
      }
    }

    // Update the apartment with the new payments
    await apartmentService.updateApartment(widget.apartment);
    // TODO: Implement sending email
    //send an email to the tenant and the owner if there bool checkboxwas checked
    // if (sendReceiptToTenant && tenant != null) {
    // final User? tenantUser = await tenant;
    // if (tenantUser != null) {
    // final Email email = Email(
    //   body: 'דיווח תשלום עבור הדירה ${widget.apartment.number}',
    //   subject: 'דיווח תשלום',
    //   recipients: [tenantUser.email],
    // );

    // // await FlutterEmailSender.send(email);
    // }
    // // }
    // if (sendReceiptToOwner && owner != null) {
    //   final User? ownerUser = await owner;
    //   if (ownerUser != null) {
    //     final Email email = Email(
    //       body: 'דיווח תשלום עבור הדירה ${widget.apartment.number}',
    //       subject: 'דיווח תשלום',
    //       recipients: [ownerUser.email],
    //     );

    //     await FlutterEmailSender.send(email);
    //   }
    // }
    ScaffoldMessenger.of(context).showSnackBar(
      SuccessMessageWidget.create(message: 'הדיווח נשלח בהצלחה'),
    );
    widget.onPaymentReported(widget.apartment);
    if (Navigator.canPop(context)) Navigator.of(context).pop();
  }
}
