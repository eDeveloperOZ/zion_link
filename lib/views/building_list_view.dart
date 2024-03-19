import 'package:flutter/material.dart';
import 'package:zion_link/features/payments/all_payments_view.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/models/expense.dart';
import 'package:zion_link/core/services/crud/building_service.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';
import 'package:zion_link/core/services/crud/expense_service.dart';
import 'package:zion_link/features/payments/attendant_payments_view.dart';
import 'package:zion_link/features/apartments/add_apartment_dialog.dart';
import 'package:zion_link/shared/widgets/apartment_row.dart';
import 'package:zion_link/features/buildings/edit_building_details_dialog.dart';
import 'package:zion_link/features/buildings/delete_building_button.dart';
import 'package:zion_link/features/expenses/expense_report_dialog.dart';
import 'package:zion_link/shared/widgets/edit_apartment_dialog.dart';
import 'package:zion_link/features/reports/report_generator_button.dart';

// StatefulWidget for displaying detailed view of a building
class BuildingDetailView extends StatefulWidget {
  final Building building;
  final Function onBuildingDeleted;
  final Function(Building) onBuildingUpdated;
  final Function onExpenseAdded;
  // Constructor requiring all the properties to be initialized
  BuildingDetailView({
    required this.building,
    required this.onBuildingDeleted,
    required this.onBuildingUpdated,
    required this.onExpenseAdded, // Initialize in constructor
  });

  @override
  State<BuildingDetailView> createState() => _BuildingDetailViewState();
}

class _BuildingDetailViewState extends State<BuildingDetailView> {
  late Building _building;
  final BuildingService _buildingService = BuildingService();
  final ApartmentService _apartmentService = ApartmentService();
  final ExpenseService _expenseService = ExpenseService();

  @override
  void initState() {
    super.initState();
    _building = widget.building;
  }

  void _onPaymentReported(Apartment updatedApartment) async {
    ApartmentService apartmentService = ApartmentService();

    setState(() {
      apartmentService.updateApartment(updatedApartment);
    });
  }

  void _onExpenseReported(Expense addedExpense) async {
    Building updatedBuilding =
        await BuildingService().getBuildingById(_building.id);
    setState(() {
      _building = updatedBuilding;
    });
  }

  /// Calculates the total balance for a given building.
  ///
  /// This function asynchronously fetches the total balance by summing up all the expenses and payments
  /// associated with the building. It ensures compatibility across iOS, Android, PC, macOS, and web platforms.
  ///
  /// Returns a [Future<double>] representing the total balance.
  Future<double> _calculateTotalBalance(String buildingId) async {
    double totalExpenses = 0.0;
    double totalPayments = 0.0;

    // Fetch expenses for the building
    List<Expense> expenses =
        await _expenseService.getAllExpensesForBuilding(buildingId);
    for (var expense in expenses) {
      totalExpenses += expense.amount;
    }

    // Fetch apartments to calculate payments
    List<Apartment> apartments =
        await _apartmentService.getAllApartmentsForBuilding(buildingId);
    for (var apartment in apartments) {
      for (var payment in apartment.payments) {
        if (payment.isConfirmed) {
          totalPayments += payment.amount;
        }
      }
    }

    // Calculate total balance
    double totalBalance = totalPayments - totalExpenses;
    return totalBalance;
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _building.name, // Building name
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 10), // Space between name and balance
                GestureDetector(
                  onTap: () => _editBalance(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4), // Padding for better touch area
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(
                          20), // Rounded corners for the balance container
                    ),
                    child: FutureBuilder<double>(
                      future: _calculateTotalBalance(_building.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            '₪${snapshot.data!.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          );
                        } else {
                          return CircularProgressIndicator(); // Show loading indicator while waiting for data
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

  Widget _buildBalanceWidget(BuildContext context) {
    return FutureBuilder<double>(
      future: _calculateTotalBalance(_building.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            onTap: () => _editBalance(context),
            child: Container(
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '\$${snapshot.data!.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        } else {
          return CircularProgressIndicator(); // Show loading indicator while waiting for data
        }
      },
    );
  }

  Future<void> _editBalance(BuildContext context) async {
    // Show dialog to input new balance
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
                    "יתרת בניין נוכחית: \₪${_building.balance.toStringAsFixed(2)}"),
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

    // If newBalance is not null, update the building's balance
    if (newBalance != null) {
      setState(() {
        _building.balance = newBalance;
      });
      await _buildingService.updateBuilding(_building);
      // Refresh the UI to reflect the updated balance
      _loadBuildingData();
    }
  }

  Future<void> _loadBuildingData() async {
    Building updatedBuilding =
        await _buildingService.getBuildingById(_building.id);
    setState(() {
      _building = updatedBuilding;
    });
  }

  Future<Widget> _buildApartmentsListView(BuildContext context) async {
    List<Apartment> apartments =
        await _apartmentService.getAllApartmentsForBuilding(_building.id);
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

    // Use ListView.builder for a list of apartments
    return ListView.builder(
      shrinkWrap: true,
      physics:
          NeverScrollableScrollPhysics(), // Prevents the ListView from scrolling
      itemCount: apartments.length,
      itemBuilder: (context, index) {
        final apartment = apartments[index];
        // Use ApartmentRow widget for each apartment
        return ApartmentRow(
          apartment: apartment,
          onPaymentReported: _onPaymentReported,
          onTap: () => _navigateToPaymentDetailView(context, apartment),
          onApartmentUpdated: (updatedApartment) {
            // Update the apartment in the building's list
            setState(() {
              _apartmentService.updateApartment(updatedApartment);
              apartments[index] = updatedApartment;
            });
          },
        );
      },
    );
  }

  // Extracted method to navigate to the payment detail view
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
            title: Text('${apartment.attendantName} - דירה'),
          ),
          body: AttendantPaymentsView(
              building: _building, payments: apartment.payments),
        ),
      ),
    );
    if (result == true) {
      _onPaymentReported(apartment);
    }
  }

  Future<Widget> _buildBottomNavigationBar() async {
    List<Apartment> apartments =
        await _apartmentService.getAllApartmentsForBuilding(_building.id);
    return BottomAppBar(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          EditBuildingDetailsDialog(
            building: _building,
            onNameChanged: (newName) {
              setState(() {
                _building.name = newName;
              });
              widget.onBuildingUpdated(_building);
            },
          ),
          ExpenseReportDialog(
            buildingId: _building.id,
            onExpenseAdded: (Expense addedExpense) {
              _onExpenseReported(addedExpense);
            },
          ),
          AllPaymentsView(building: _building),
          AddApartmentDialog(
              buildingId: _building.id,
              onAdd: (Apartment newApartment) async {
                await _apartmentService.addApartment(newApartment);
                apartments.add(newApartment);
                setState(() {});
              }),
          EditApartmentDialog(
            apartments: apartments,
            onApartmentsUpdated: (List<Apartment> updatedApartments) async {
              apartments = updatedApartments;
              await _buildingService.updateBuilding(_building);
              setState(() {});
            },
          ),
          ReportGeneratorButton(building: _building),
          DeleteBuildingButton(
            buildingID: _building.id,
            onBuildingDeleted: () async {
              await _buildingService.deleteBuilding(_building.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<Widget> _buildBody(BuildContext context) async {
    return SingleChildScrollView(
      child: Column(
        children: [
          await _buildApartmentsListView(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Building the UI for the building detail view
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<Widget>(
        future: _buildBody(context),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data ??
                Container(); // Return the built widget or an empty container if null
          } else {
            return Center(
                child:
                    CircularProgressIndicator()); // Show a loading spinner while waiting
          }
        },
      ),
      bottomNavigationBar: FutureBuilder<Widget>(
        future: _buildBottomNavigationBar(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data ??
                Container(); // Return the built widget or an empty container if null
          } else {
            return Container(); // Optionally, return an empty container or a placeholder widget
          }
        },
      ),
    );
  }
}
