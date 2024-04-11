import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/core/models/payment.dart';
import 'package:tachles/core/models/user.dart';
import 'package:tachles/core/services/crud/payment_service.dart';
import 'package:tachles/core/services/crud/user_service.dart';
import 'package:tachles/features/payments/apartment_payments_view.dart';
import 'package:tachles/features/payments/income_report_screen.dart';
import 'package:tachles/features/users/create_user_dialog.dart';
import 'package:tachles/features/users/edit_user_dialog.dart';
import 'package:tachles/shared/widgets/apartment_details_widget.dart';
import 'package:tachles/shared/widgets/error_message_widget.dart';

class ApartmentRow extends StatefulWidget {
  final Apartment apartment;
  final Function(Apartment) onPaymentReported;
  final VoidCallback onTap;
  final Function(Apartment) onApartmentUpdated;
  User? tenant;
  User? owner;

  ApartmentRow({
    Key? key,
    required this.apartment,
    required this.onTap,
    required this.onPaymentReported,
    required this.onApartmentUpdated,
  }) : super(key: key);

  @override
  _ApartmentRowState createState() => _ApartmentRowState();
}

class _ApartmentRowState extends State<ApartmentRow> {
  final PaymentService _paymentService = PaymentService();
  final UserService _userService = UserService();
  Future<User?>? _tenantFuture;
  Future<User?>? _ownerFuture;

  @override
  void initState() {
    super.initState();
    _fetchTenantAndOwner();
  }

  void _fetchTenantAndOwner() {
    if (widget.apartment.tenantId.isNotEmpty) {
      _tenantFuture = _userService.getUserById(widget.apartment.tenantId);
    } else {
      _tenantFuture = Future.value(User.empty());
    }

    if (widget.apartment.ownerId.isNotEmpty) {
      _ownerFuture =
          Future.value(_userService.getUserById(widget.apartment.ownerId));
    } else {
      _ownerFuture = Future.value();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: FutureBuilder<List<User?>>(
              future: Future.wait([_tenantFuture!, _ownerFuture!]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final tenant = snapshot.data![0];
                  final owner = snapshot.data![1];
                  return ApartmentDetailsWidget(
                    apartment: widget.apartment,
                    tenant: tenant,
                    owner: owner,
                    onUserTap: _handleUserTap,
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          Expanded(
            child: Tooltip(
              message: 'צפה בתשלומים',
              child: GestureDetector(
                onTap: () => _showPayments(context),
                child: PaymentDetailsWidget(
                  future: _paymentService
                      .readAllPaymentsForApartment(widget.apartment.id),
                  yearlyPaymentAmount: widget.apartment.yearlyPaymentAmount,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _handleReportPaymentTap,
            child: Tooltip(
              message: 'דווח תשלום',
              child: Row(
                children: [
                  Icon(Icons.attach_money),
                  Text('דווח', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPayments(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.50,
            child: ApartmentPaymentsView(apartment: widget.apartment),
          ),
        );
      },
    );
    setState(() {});
  }

  void _handleUserTap(BuildContext context, User? user) {
    if (user == null || user.id.isEmpty) {
      if (user == null) {
        _showCreateUserDialog(context, UserType.owner);
      } else {
        _showCreateUserDialog(context, UserType.tenant);
      }
    } else {
      _showEditUserDialog(context, user);
    }
    setState(() {});
  }

  void _showCreateUserDialog(BuildContext context, UserType role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateUserDialog(
            buildingId: widget.apartment.buildingId,
            role: role,
            apartmentSelectedId: widget.apartment.id,
            apartment: widget.apartment);
      },
    ).then((updatedApartment) {
      if (mounted && updatedApartment != null) {
        setState(() {
          widget.onApartmentUpdated(updatedApartment);
        });
      }
    });
  }

  void _showEditUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditUserDialog(
            user: user, buildingId: widget.apartment.buildingId);
      },
    ).then((_) {
      setState(() {});
    });
  }

  void _handleReportPaymentTap() {
    if (widget.apartment.tenantId.isEmpty || widget.apartment.ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorMessageWidget.create(
          message: 'נא למלא דייר ובעלים עבור הדירה',
        ),
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('דייר ובעלים חסרים'),
            content: Text('נראה שהדירה זקוקה לדייר ולבעלים. האם תרצה להוסיף?'),
            actions: <Widget>[
              Visibility(
                visible: widget.apartment.tenantId.isEmpty,
                child: TextButton(
                  child: Text('הוסף דייר'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showCreateUserDialog(context, UserType.tenant);
                  },
                ),
              ),
              Visibility(
                visible: widget.apartment.ownerId.isEmpty,
                child: TextButton(
                  child: Text('הוסף בעלים'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showCreateUserDialog(context, UserType.owner);
                  },
                ),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.50,
              child: IncomeReportScreen(
                apartment: widget.apartment,
                onPaymentReported: widget.onPaymentReported,
              ),
            ),
          );
        },
      ).then((_) => widget.onPaymentReported(widget.apartment));
    }
  }
}

class PaymentDetailsWidget extends StatelessWidget {
  final Future<List<Payment>> future;
  final double yearlyPaymentAmount;

  const PaymentDetailsWidget({
    Key? key,
    required this.future,
    required this.yearlyPaymentAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Payment>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final double totalConfirmedPayments = snapshot.data!
              .where((payment) => payment.isConfirmed)
              .map((payment) => payment.amount)
              .fold(0.0, (prev, amount) => prev + amount);
          return Text(
            'תשלום שנתי ${totalConfirmedPayments.toStringAsFixed(2)}/${yearlyPaymentAmount.toDouble().toStringAsFixed(2)}',
            style: TextStyle(fontSize: 25),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return CircularProgressIndicator();
      },
    );
  }
}
