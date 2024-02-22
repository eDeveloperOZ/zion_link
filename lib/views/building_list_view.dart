// Importing necessary packages and files for the UI and functionality
import 'package:flutter/material.dart';
import 'package:zion_link/views/all_payments_view.dart';
import '../models/building.dart';
import '../models/apartment.dart';
import '../models/expense.dart';
import '../services/building_service.dart';
import 'payments_detail_view.dart';
import '../widgets/add_apartment_dialog.dart';
import '../widgets/apartment_row.dart';
import '../widgets/edit_building_details_dialog.dart';
import '../widgets/delete_building_dialog.dart';
import '../widgets/expense_report_dialog.dart';
import '../widgets/edit_apartment_dialog.dart';
import '../services/expense_service.dart';

// StatefulWidget for displaying detailed view of a building
class BuildingDetailView extends StatefulWidget {
  final Building building; // Make building final
  final Function onBuildingDeleted; // Callback when a building is deleted
  final Function(Building)
      onBuildingUpdated; // Callback when a building is updated

  // Constructor requiring all the properties to be initialized
  BuildingDetailView({
    required this.building,
    required this.onBuildingDeleted,
    required this.onBuildingUpdated,
  });

  @override
  State<BuildingDetailView> createState() => _BuildingDetailViewState();
}

class _BuildingDetailViewState extends State<BuildingDetailView> {
  late Building _building; // Use a local mutable building object
  final BuildingService _buildingService =
      BuildingService(); // Create an instance of BuildingService

  @override
  void initState() {
    super.initState();
    _building =
        widget.building; // Initialize _building with the widget's building
  }

  // Function to add a new apartment to the building and save the update
  void _addApartmentAndSave(Apartment newApartment) async {
    // Assuming BuildingService has a method to handle adding an apartment
    await _buildingService.addApartmentToBuilding(_building.id, newApartment);
    // Update the local state to reflect the change
    setState(() {
      _building.apartments.add(newApartment);
    });
  }

  // Function to update the list of buildings in local storage
  Future<void> _updateBuildingsInStorage() async {
    await _buildingService.updateBuilding(_building);
  }

  // Function to fetch and update the expenses for the building
  Future<void> _fetchAndUpdateExpenses() async {
    // Assuming ExpenseService has a method to fetch expenses for a building
    List<Expense> updatedExpenses =
        await ExpenseService().fetchExpenses(_building.id);
    setState(() {
      _building.expenses = updatedExpenses;
    });
  }

  void _onPaymentReported() async {
    Building updatedBuilding =
        await BuildingService().fetchBuilding(_building.id); // Use _building.id
    setState(() {
      _building = updatedBuilding; // Update the local _building object
    });
  }

  Widget _buildApartmentsListView(BuildContext context) {
    if (_building.apartments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('No apartments'),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _building.apartments.length,
        itemBuilder: (context, index) {
          final apartment = _building.apartments[index];
          return ApartmentRow(
            apartment: apartment,
            onPaymentReported: _onPaymentReported,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: Text('${apartment.attendantName} - דירה'),
                    ),
                    body: PaymentsDetailView(payments: apartment.payments),
                  ),
                ),
              );
              if (result == true) {
                _onPaymentReported();
              }
            },
          );
        },
      );
    }
  }

  Widget _buildBottomNavigationBar() {
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
            expenses: _building.expenses,
            buildingId: _building.id,
            onDialogOpened: _fetchAndUpdateExpenses,
          ),
          AllPaymentsView(building: _building),
          AddApartmentDialog(onAdd: (Apartment apartment) {
            _addApartmentAndSave(apartment);
          }),
          EditApartmentDialog(
            apartments: _building.apartments,
            onApartmentsUpdated: (List<Apartment> updatedApartments) {
              // Assuming you have a method to handle the updated list of apartments
              setState(() {
                _building.apartments = updatedApartments;
              });
              // Optionally, update the building in storage or backend
              _updateBuildingsInStorage();
            },
          ),
          IconButton(icon: Icon(Icons.logout, size: 24), onPressed: () {}),
          DeleteBuildingDialog(
            buildingName: _building.name,
            onBuildingDeleted: () async {
              await _buildingService.deleteBuilding(_building.id);
              Navigator.pop(
                  context); // Assuming you want to close the dialog and return to the previous screen
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_building.name), // Display the building name
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildApartmentsListView(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Building the UI for the building detail view
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
