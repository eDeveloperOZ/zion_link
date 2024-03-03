import 'package:flutter/material.dart';
import '../models/building.dart';
import 'attendant_payments_view.dart';

class AllPaymentsView extends StatefulWidget {
  final Building building;

  const AllPaymentsView({Key? key, required this.building}) : super(key: key);

  @override
  _AllPaymentsViewState createState() => _AllPaymentsViewState();
}

class _AllPaymentsViewState extends State<AllPaymentsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.manage_accounts, size: 24),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return BuildingPaymentsView(building: widget.building);
              },
            );
          },
        ),
        Text('כל התשלומים'),
      ],
    );
  }
}

class BuildingPaymentsView extends StatefulWidget {
  final Building building;

  const BuildingPaymentsView({Key? key, required this.building})
      : super(key: key);

  @override
  _BuildingPaymentsViewState createState() => _BuildingPaymentsViewState();
}

class _BuildingPaymentsViewState extends State<BuildingPaymentsView> {
  String? selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    List<Widget> paymentDetailsViews = [];

    for (var apartment in widget.building.apartments) {
      var filteredPayments = selectedPaymentMethod == null
          ? apartment.payments
          : apartment.payments
              .where(
                  (payment) => payment.paymentMethod == selectedPaymentMethod)
              .toList();

      if (filteredPayments.isNotEmpty) {
        paymentDetailsViews.add(Text(
          '${apartment.attendantName}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
        paymentDetailsViews
            .add(AttendantPaymentsView(payments: filteredPayments));
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('תשלומים של ${widget.building.name}'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(bottom: 10), // Adjust if necessary
          children: paymentDetailsViews,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.all_inclusive),
                tooltip: 'הצג הכל',
                onPressed: () => setState(() => selectedPaymentMethod = null),
              ),
              IconButton(
                icon: Icon(Icons.credit_card),
                tooltip: 'צ׳ק',
                onPressed: () => setState(() => selectedPaymentMethod = "צ׳ק"),
              ),
              IconButton(
                icon: Icon(Icons.money),
                tooltip: 'מזומן',
                onPressed: () =>
                    setState(() => selectedPaymentMethod = "מזומן"),
              ),
              IconButton(
                icon: Icon(Icons.account_balance),
                tooltip: 'העברה בנקאית',
                onPressed: () =>
                    setState(() => selectedPaymentMethod = "העברה בנקאית"),
              ),
              IconButton(
                icon: Icon(Icons.account_balance_wallet),
                tooltip: 'הוראת קבע',
                onPressed: () =>
                    setState(() => selectedPaymentMethod = "הוראת קבע"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
