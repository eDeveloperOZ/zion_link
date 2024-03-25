import 'package:flutter/material.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/models/expense.dart'; // Ensure this import is correct
import 'package:zion_link/core/models/payment.dart'; // Ensure this import is correct
import 'package:zion_link/core/services/crud/expense_service.dart';
import 'package:zion_link/core/services/crud/payment_service.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';

/// Displays a report view showing the balance of a building by listing all payments and expenses.
class ReportBalanceView extends StatelessWidget {
  final Building building;
  final ExpenseService _expenseService = ExpenseService();
  final PaymentService _paymentService = PaymentService();
  final ApartmentService _apartmentService = ApartmentService();

  ReportBalanceView({Key? key, required this.building}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('דוח יתרות'),
      ),
      body: FutureBuilder(
        future: _fetchData(),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final payments = snapshot.data![0] as List<Payment>;
            final expenses = snapshot.data![1] as List<Expense>;

            final totalPayments =
                payments.fold(0.0, (sum, payment) => sum + payment.amount);
            final totalExpenses =
                expenses.fold(0.0, (sum, expense) => sum + expense.amount);

            final balance = building.balance + totalPayments - totalExpenses;

            return Column(
              children: [
                Text('הכנסות:'),
                Expanded(
                  child: ListView.builder(
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return ListTile(
                        title: Text('תשלום: ${payment.amount}'),
                      );
                    },
                  ),
                ),
                Text('הוצאות:'),
                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return ListTile(
                        title: Text('הוצאה: ${expense.amount}'),
                      );
                    },
                  ),
                ),
                Text('יתרת הבניין: $balance'),
              ],
            );
          } else {
            return Text('No data found');
          }
        },
      ),
    );
  }

  /// Fetches all necessary data for the report, including apartments, payments, and expenses.
  Future<List<dynamic>> _fetchData() async {
    final apartmentsFuture =
        _apartmentService.readAllApartmentsForBuilding(building.id);
    final apartments = await apartmentsFuture;

    final paymentsFutures = apartments
        .map((apartment) =>
            _paymentService.readAllPaymentsForApartment(apartment.id))
        .toList();
    final expensesFuture =
        _expenseService.readAllExpensesForBuilding(building.id);

    final results =
        await Future.wait([Future.wait(paymentsFutures), expensesFuture]);

    // Flatten the list of lists of payments into a single list of payments.
    final payments = results[0].expand((x) => x as Iterable<Payment>).toList();
    final expenses = results[1] as List<Expense>;

    return [payments, expenses];
  }
}
