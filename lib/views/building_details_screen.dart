import 'package:flutter/material.dart';
import 'package:tachles/features/expenses/all_expenses_button.dart';
import 'package:tachles/features/payments/all_payments_view.dart';
import 'package:tachles/core/models/building.dart';
import 'package:tachles/core/models/expense.dart';
import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/core/models/payment.dart';
import 'package:tachles/core/services/crud/building_service.dart';
import 'package:tachles/core/services/crud/apartment_service.dart';
import 'package:tachles/core/services/crud/expense_service.dart';
import 'package:tachles/core/services/crud/payment_service.dart';
import 'package:tachles/features/payments/apartment_payments_view.dart';
import 'package:tachles/features/users/service_provider_details_screen.dart';
import 'package:tachles/shared/widgets/apartment_row.dart';
import 'package:tachles/features/buildings/edit_building_details_dialog.dart';
import 'package:tachles/features/buildings/delete_building_button.dart';
import 'package:tachles/features/expenses/expense_report_dialog.dart';
import 'package:tachles/features/receipts_and_reports/report_generator_button.dart';

class BuildingsDetailsScreen extends StatefulWidget {
  final Building building;

  BuildingsDetailsScreen({required this.building});

  @override
  State<BuildingsDetailsScreen> createState() => _BuildingsDetailsScreenState();
}

class _BuildingsDetailsScreenState extends State<BuildingsDetailsScreen> {
  late Building _building;
  final BuildingService _buildingService = BuildingService();
  final ApartmentService _apartmentService = ApartmentService();
  final ExpenseService _expenseService = ExpenseService();
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    _building = widget.building;
  }

  void _onPaymentReported(Apartment updatedApartment) async {
    setState(() {
      _apartmentService.updateApartment(updatedApartment);
    });
  }

  void _onExpenseReported(Expense addedExpense) async {
    try {
      Building? updatedBuilding =
          await _buildingService.getBuildingById(_building.id);
      setState(() {
        _building = updatedBuilding ?? _building;
      });
    } catch (e) {
      // Handle error and show appropriate message
      print('Failed to update building: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update building')),
      );
    }
  }

  Future<double> _calculateTotalBalance(String buildingId) async {
    double totalPayments = 0;
    double totalExpenses = 0;

    try {
      List<Expense> expenses =
          await _expenseService.readAllExpensesForBuilding(buildingId);
      expenses.forEach((expense) {
        totalExpenses += expense.amount;
      });

      List<Apartment> apartments =
          await _apartmentService.readAllApartmentsForBuilding(buildingId);

      for (Apartment apartment in apartments) {
        List<Payment> payments =
            await _paymentService.readAllPaymentsForApartment(apartment.id);
        payments.forEach((payment) {
          if (payment.isConfirmed) {
            totalPayments += payment.amount;
          }
        });
      }

      double totalBalance = totalPayments - totalExpenses + _building.balance;
      return totalBalance;
    } catch (e) {
      // Handle error and show appropriate message
      print('Failed to calculate total balance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to calculate total balance')),
      );
      return 0;
    }
  }

  Future<void> _editBalance(BuildContext context) async {
    final TextEditingController _controller = TextEditingController();
    final newBalance = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('עדכן יתרת בניין'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText:
                  "יתרת בניין נוכחית: \₪${_building.balance.toStringAsFixed(2)}",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('עדכן יתרה'),
              onPressed: () {
                final double? enteredBalance =
                    double.tryParse(_controller.text);
                if (enteredBalance != null) {
                  Navigator.of(context).pop(enteredBalance);
                }
              },
            ),
            TextButton(
              child: Text('ביטול'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (newBalance != null) {
      setState(() {
        _building.balance = newBalance;
      });
      try {
        await _buildingService.updateBuilding(_building);
        _loadBuildingData();
      } catch (e) {
        // Handle error and show appropriate message
        print('Failed to update building balance: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update building balance')),
        );
      }
    }
  }

  Future<void> _loadBuildingData() async {
    try {
      Building? updatedBuilding =
          await _buildingService.getBuildingById(_building.id);
      setState(() {
        _building = updatedBuilding ?? _building;
      });
    } catch (e) {
      // Handle error and show appropriate message
      print('Failed to load building data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load building data')),
      );
    }
  }

  Future<void> _navigateToPaymentDetailView(
      BuildContext context, Apartment apartment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
              },
            ),
            title: Text('${apartment.tenantId} - דירה'),
          ),
          body: ApartmentPaymentsView(apartment: apartment),
        ),
      ),
    );
    if (result == true) {
      _onPaymentReported(apartment);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bottomBarItems = [
      EditBuildingDetailsDialog(
        building: _building,
        onNameChanged: (newName) {
          setState(() {
            _building.name = newName;
          });
        },
      ),
      ExpenseReportDialog(
        buildingId: _building.id,
        onExpenseAdded: _onExpenseReported,
      ),
      AllPaymentsView(building: _building),
      ServiceProviderDetailsScreen(buildingId: _building.id),
      AllExpensesButton(buildingId: _building.id),
      ReportGeneratorButton(building: _building),
      DeleteBuildingButton(buildingID: _building.id),
    ];

    return Scaffold(
      appBar: _AppBarWidget(
        building: _building,
        editBalance: _editBalance,
        calculateTotalBalance: _calculateTotalBalance,
      ),
      body: FutureBuilder<List<Apartment>>(
        future: _apartmentService.readAllApartmentsForBuilding(_building.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _ApartmentsListView(
              apartments: snapshot.data ?? [],
              onPaymentReported: _onPaymentReported,
              onApartmentUpdated: (updatedApartment) {
                setState(() {
                  _apartmentService.updateApartment(updatedApartment);
                });
              },
              onTap: (apartment) =>
                  _navigateToPaymentDetailView(context, apartment),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: _buildResponsiveBottomAppBar(bottomBarItems),
    );
  }

  Widget _buildResponsiveBottomAppBar(List<Widget> bottomBarItems) {
    double totalItemsWidth = bottomBarItems.length * 100.0;
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 90,
        width: totalItemsWidth > screenWidth ? totalItemsWidth : screenWidth,
        child: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: bottomBarItems,
          ),
        ),
      ),
    );
  }
}

class _ApartmentsListView extends StatelessWidget {
  final List<Apartment> apartments;
  final Function(Apartment) onPaymentReported;
  final Function(Apartment) onApartmentUpdated;
  final Function(Apartment) onTap;

  const _ApartmentsListView({
    required this.apartments,
    required this.onPaymentReported,
    required this.onApartmentUpdated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (apartments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text('אין דירות להצגה'),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: apartments.length,
      itemBuilder: (context, index) {
        final apartment = apartments[index];
        return ApartmentRow(
          apartment: apartment,
          onPaymentReported: onPaymentReported,
          onTap: () => onTap(apartment),
          onApartmentUpdated: onApartmentUpdated,
        );
      },
    );
  }
}

class _AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Building building;
  final Function(BuildContext) editBalance;
  final Future<double> Function(String) calculateTotalBalance;

  _AppBarWidget({
    required this.building,
    required this.editBalance,
    required this.calculateTotalBalance,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  building.name,
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () => editBalance(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FutureBuilder<double>(
                      future: calculateTotalBalance(building.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            'יתרה נוכחית: ₪${snapshot.data!.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            'Failed to calculate balance',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
