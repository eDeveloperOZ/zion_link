import 'package:flutter/material.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/models/expense.dart';
import 'package:zion_link/core/models/payment.dart';
import 'package:zion_link/core/services/crud/expense_service.dart';
import 'package:zion_link/core/services/crud/payment_service.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';
import 'package:zion_link/core/services/file_upload_service.dart';

/// Displays a report of payments and expenses for a specific building.
class ReportBalanceScreen extends StatelessWidget {
  final Building building;
  final ExpenseService _expenseService = ExpenseService();
  final PaymentService _paymentService = PaymentService();
  final ApartmentService _apartmentService = ApartmentService();

  ReportBalanceScreen({Key? key, required this.building}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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

          return SingleChildScrollView(
            child: Column(
              children: [
                Text('הכנסות:'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return ListTile(
                      title:
                          Text('תשלום: ${payment.amount.toStringAsFixed(2)}'),
                    );
                  },
                ),
                Text('הוצאות:'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      title:
                          Text('הוצאה: ${expense.amount.toStringAsFixed(2)}'),
                    );
                  },
                ),
                Text('יתרה: ${balance.toStringAsFixed(2)}'),
                ElevatedButton(
                  onPressed: () async {
                    final reportContent =
                        _generateReportContent(payments, expenses, balance);
                    final fileName =
                        'Report_${DateTime.now().toIso8601String()}.txt';
                    try {
                      await FileUploadService.saveContentToFile(
                          fileName, reportContent);
                      // Optionally show a message to the user that the file was saved successfully
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('הדוח נשמר בהצלחה')),
                      );
                    } catch (e) {
                      // Handle file save error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('שגיאה בשמירת הדוח')),
                      );
                    }
                  },
                  child: Text('שמור דוח'),
                ),
              ],
            ),
          );
        } else {
          return Text('No data available');
        }
      },
    );
  }

  /// Fetches payments and expenses data asynchronously.
  Future<List<dynamic>> _fetchData() async {
    final apartmentsFuture =
        _apartmentService.readAllApartmentsForBuilding(building.id);
    final expensesFuture =
        _expenseService.readAllExpensesForBuilding(building.id);
    final apartments = await apartmentsFuture;
    final expenses = await expensesFuture;
    final List<Payment> payments = [];
    for (final apartment in apartments) {
      final paymentsForApartment =
          await _paymentService.readAllPaymentsForApartment(apartment.id);
      payments.addAll(paymentsForApartment);
    }
    return [payments, expenses];
  }

  /// Generates a string content for the report based on payments, expenses, and balance.
  String _generateReportContent(
      List<Payment> payments, List<Expense> expenses, double balance) {
    final StringBuffer reportBuffer = StringBuffer();
    reportBuffer.writeln('דוח כספים לבניין: ${building.name}');
    reportBuffer.writeln('הכנסות:');
    payments.forEach((payment) {
      reportBuffer.writeln('תשלום: ${payment.amount.toStringAsFixed(2)}');
    });
    reportBuffer.writeln('הוצאות:');
    expenses.forEach((expense) {
      reportBuffer.writeln('הוצאה: ${expense.amount.toStringAsFixed(2)}');
    });
    reportBuffer.writeln('יתרה: ${balance.toStringAsFixed(2)}');
    return reportBuffer.toString();
  }
}
