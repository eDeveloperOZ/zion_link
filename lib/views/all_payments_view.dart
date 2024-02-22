import 'package:flutter/material.dart';
import '../models/building.dart';
import 'payments_detail_view.dart';

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
            // Navigate to PaymentsDetailView
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BuildingPaymentsView(building: widget.building)),
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
      // Filter payments by selectedPaymentMethod if not null
      var filteredPayments = selectedPaymentMethod == null
          ? apartment.payments
          : apartment.payments
              .where(
                  (payment) => payment.paymentMethod == selectedPaymentMethod)
              .toList();

      if (filteredPayments.isNotEmpty) {
        // Add a header for each apartment
        paymentDetailsViews.add(Text(
          '${apartment.attendantName}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
        // Add the PaymentsDetailView for the filtered payments
        paymentDetailsViews.add(PaymentsDetailView(payments: filteredPayments));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('תשלומים של ${widget.building.name}'),
      ),
      body: ListView(
        children: paymentDetailsViews,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.all_inclusive),
              onPressed: () => setState(() => selectedPaymentMethod = null),
            ),
            IconButton(
              icon: Icon(Icons.credit_card),
              onPressed: () =>
                  setState(() => selectedPaymentMethod = "credit card"),
            ),
            IconButton(
              icon: Icon(Icons.money),
              onPressed: () => setState(() => selectedPaymentMethod = "cash"),
            ),
            IconButton(
              icon: Icon(Icons.account_balance),
              onPressed: () =>
                  setState(() => selectedPaymentMethod = "bank transfer"),
            ),
          ],
        ),
      ),
    );
  }
}
