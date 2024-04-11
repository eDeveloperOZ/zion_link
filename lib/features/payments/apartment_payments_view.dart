import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/core/models/payment.dart';
import 'package:tachles/core/models/user.dart';
import 'package:tachles/core/services/crud/apartment_service.dart';
import 'package:tachles/core/services/crud/payment_service.dart';
import 'package:tachles/core/services/crud/building_service.dart';
import 'package:tachles/core/services/crud/user_service.dart';
import 'package:tachles/shared/widgets/delete_button.dart';
import 'package:tachles/shared/widgets/success_message_widget.dart';
import 'package:tachles/shared/widgets/notifier_widget.dart';
import 'package:tachles/features/receipts_and_reports/receipt_view.dart';
import 'package:tachles/shared/widgets/error_message_widget.dart';

class ApartmentPaymentsView extends StatefulWidget {
  final Apartment apartment;
  final String? selectedFilter;

  ApartmentPaymentsView({required this.apartment, this.selectedFilter});

  @override
  _ApartmentPaymentsViewState createState() => _ApartmentPaymentsViewState();
}

class _ApartmentPaymentsViewState extends State<ApartmentPaymentsView> {
  final PaymentService _paymentService = PaymentService();
  final BuildingService _buildingService = BuildingService();
  final UserService _userService = UserService();
  String? tenantName;

  @override
  void initState() {
    super.initState();
    _fetchTenantName();
  }

  Future<void> _fetchTenantName() async {
    final tenant = await _userService.getUserById(widget.apartment.tenantId);
    if (tenant != null) {
      setState(() {
        tenantName = '${tenant.firstName} ${tenant.lastName ?? ''}';
      });
    }
  }

  List<Payment> filterPayments(List<Payment> payments, String? filter) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    final List<Payment> madePaymentsMonths = payments
        .where((payment) =>
            DateTime.parse(payment.periodCoverageStart).year == currentYear)
        .toList();
    // MonthsToSkip is a list of months of paymnt.periodCoverageStart month from madePaymentsMonths list
    final MonthsToSkip = madePaymentsMonths
        .map((payment) => DateTime.parse(payment.periodCoverageStart).month)
        .toList();

    switch (filter) {
      case 'all':
        final madePayments = payments
            .where((payment) => payment.dateMade.year == currentYear)
            .toList();

        final predictedPayments = <Payment>[];
        for (var month = 1; month <= 12; month++) {
          // Skip months for which a payment has already been made
          if (!MonthsToSkip.contains(month)) {
            final periodStart = DateTime(currentYear, month);
            final periodEnd =
                DateTime(currentYear, month + 1).subtract(Duration(days: 1));
            predictedPayments.add(Payment(
              id: '',
              apartmentId: widget.apartment.id,
              madeByName: '',
              amount: widget.apartment.yearlyPaymentAmount / 12,
              dateMade: DateTime(currentYear, month),
              periodCoverageStart: periodStart.toString(),
              periodCoverageEnd: periodEnd.toString(),
              paymentMethod: '',
              reason: 'pesudo payment for prediction',
              isConfirmed: false,
            ));
          }
        }

        return [...madePayments, ...predictedPayments];
      case 'prediction':
        final predictedPayments = <Payment>[];
        for (var month = currentMonth + 1; month <= 12; month++) {
          // Skip months for which a payment has already been made
          if (MonthsToSkip.contains(month)) {
            continue;
          }
          final periodStart = DateTime(currentYear, month);
          final periodEnd =
              DateTime(currentYear, month + 1).subtract(Duration(days: 1));
          predictedPayments.add(Payment(
            id: '',
            apartmentId: widget.apartment.id,
            madeByName: '',
            amount: widget.apartment.yearlyPaymentAmount / 12,
            dateMade: DateTime(currentYear, month),
            periodCoverageStart: periodStart.toString(),
            periodCoverageEnd: periodEnd.toString(),
            paymentMethod: '',
            reason: '',
            isConfirmed: false,
          ));
        }
        return predictedPayments;
      case 'made':
        return payments;
      case 'past':
        return payments
            .where((payment) =>
                payment.dateMade.isBefore(DateTime(currentYear, currentMonth)))
            .toList();
      case 'approved':
        return payments.where((payment) => payment.isConfirmed).toList();
      case 'overdue':
        final overduePayments = <Payment>[];
        for (var month = 1; month <= currentMonth; month++) {
          final hasPaymentForMonth = payments.any((payment) =>
              payment.dateMade.year == currentYear &&
              payment.dateMade.month == month);
          if (!hasPaymentForMonth) {
            final periodStart = DateTime(currentYear, month);
            final periodEnd =
                DateTime(currentYear, month + 1).subtract(Duration(days: 1));
            overduePayments.add(Payment(
              id: '',
              apartmentId: widget.apartment.id,
              madeByName: '',
              amount: widget.apartment.yearlyPaymentAmount / 12,
              dateMade: DateTime(currentYear, month),
              periodCoverageStart: periodStart.toString(),
              periodCoverageEnd: periodEnd.toString(),
              paymentMethod: '',
              reason: '',
              isConfirmed: false,
            ));
          }
        }
        return overduePayments;
      default:
        return payments;
    }
  }

  Color _getPaymentCardColor(Payment payment) {
    final now = DateTime.now();

    // Future unconfirmed, but reported payments will be yellow
    if (!payment.isConfirmed &&
        DateTime.parse(payment.periodCoverageStart).isAfter(now) &&
        payment.id.isNotEmpty) {
      return Colors.yellow;
    }
    // Future unconfirmed and unreported payments will be white
    else if (!payment.isConfirmed &&
        DateTime.parse(payment.periodCoverageStart).isAfter(now) &&
        !payment.id.isEmpty) {
      return Colors.white;
    }
    // Past unconfirmed, reported or not payments will be red
    else if (!payment.isConfirmed &&
        DateTime.parse(payment.periodCoverageStart).isBefore(now)) {
      return Colors.red;
    }
    // Any confirmed, reported payments will be green
    else if (payment.isConfirmed) {
      return Colors.green;
    }
    // All other cases will be white
    else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Payment>>(
      future: _paymentService.readAllPaymentsForApartment(widget.apartment.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final payments = snapshot.data ?? [];
          final filteredPayments =
              filterPayments(payments, widget.selectedFilter);

          if (filteredPayments.isEmpty) {
            return ErrorMessageWidget.createSimpleErrorMessage(
              message: 'לא נעשו תשלומים עדיין',
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: filteredPayments.length,
            itemBuilder: (context, index) {
              final payment = filteredPayments[index];
              final monthName = DateFormat('MMMM', 'he').format(
                  DateTime.parse(payment.periodCoverageStart.toString()));
              return Card(
                margin: EdgeInsets.all(8.0),
                color: _getPaymentCardColor(payment),
                child: ListTile(
                  title: Text('${payment.amount}'),
                  subtitle: Text(
                      '${DateFormat('HH:mm MM/dd').format(payment.dateMade)} - ${payment.paymentMethod}ֿ\nעבור חודש: $monthName'),
                  trailing: _build_payment_actions(context, payment),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _build_payment_actions(BuildContext context, Payment payment) {
    if (payment.reason == 'pesudo payment for prediction') {
      return FutureBuilder<User?>(
        future: _userService.getUserById(widget.apartment.tenantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final tenant = snapshot.data;
            if (tenant != null) {
              return NotifierWidget(
                message:
                    'היי ${tenant.firstName}, רציתי להזכיר לך על תשלום השכירות שלך לחודש הקרוב',
                phoneNumber: tenant.phoneNumber ?? '',
                tooltip: 'הודעת איחור לדייר',
              );
            } else {
              return Text('Tenant not found');
            }
          }
        },
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!payment.isConfirmed)
          ElevatedButton(
            child: Text('אשר תשלום'),
            onPressed: () async {
              final paymentToUpdate = await _paymentService.getPaymentById(
                  widget.apartment.id, payment.id);
              if (paymentToUpdate != null) {
                paymentToUpdate.isConfirmed = true;
                await _paymentService.updatePayment(paymentToUpdate);
                setState(() {});
              }
            },
          ),
        DeleteButton(
          requirePassword: true,
          onDelete: () async {
            await _paymentService.deletePayment(payment.id);
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              SuccessMessageWidget.create(message: 'התשלום נמחק בהצלחה'),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.receipt),
          onPressed: () async {
            final tenantName = widget.apartment.tenantId;
            final buildingId = widget.apartment.buildingId;
            final building = await _buildingService.getBuildingById(buildingId);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ReceiptView(
                  payment: payment,
                  tenantName: tenantName,
                  buildingAddress: building?.address ?? '',
                );
              },
            );
          },
        ),
      ],
    );
  }
}
