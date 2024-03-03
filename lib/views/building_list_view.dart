import 'package:flutter/material.dart';
import 'package:zion_link/views/all_payments_view.dart';
import '../models/building.dart';
import '../models/apartment.dart';
import '../services/building_service.dart';
import '../services/apartment_service.dart';
import 'attendant_payments_view.dart';
import '../widgets/add_apartment_dialog.dart';
import '../widgets/apartment_row.dart';
import '../widgets/edit_building_details_dialog.dart';
import '../widgets/delete_building_button.dart';
import '../widgets/expense_report_dialog.dart';
import '../widgets/edit_apartment_dialog.dart';
import '../widgets/report_generator_button.dart';

// StatefulWidget for displaying detailed view of a building
class BuildingDetailView extends StatefulWidget {
  final Building building; // Make building final
  final Function onBuildingDeleted; // Callback when a building is deleted
  final Function(Building)
      onBuildingUpdated; // Callback when a building is updated
  final Function
      onExpenseAdded; // Add this callback for when an expense is added

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

  @override
  void initState() {
    super.initState();
    _building = widget.building;
  }

  void _onPaymentReported() async {
    Building updatedBuilding =
        await BuildingService().getBuildingById(_building.id);
    setState(() {
      _building = updatedBuilding;
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Align title and balance
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content
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
                      future:
                          _buildingService.calculateTotalBalance(_building.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            '\$${snapshot.data!.toStringAsFixed(2)}',
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
      future: _buildingService.calculateTotalBalance(_building.id),
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
    // Implement the logic to edit the balance
    // For simplicity, let's assume you use a dialog to input the new balance
    // and then update the building's balance using _buildingService.updateBuilding(_building);
  }

  Widget _buildApartmentsListView(BuildContext context) {
    // Check if there are no apartments to display a simple message
    if (_building.apartments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('אין דירות להצגה'),
      );
    }

    // Use ListView.builder for a list of apartments
    return ListView.builder(
      shrinkWrap: true,
      physics:
          NeverScrollableScrollPhysics(), // Prevents the ListView from scrolling
      itemCount: _building.apartments.length,
      itemBuilder: (context, index) {
        final apartment = _building.apartments[index];
        // Use ApartmentRow widget for each apartment
        return ApartmentRow(
          apartment: apartment,
          onPaymentReported: _onPaymentReported,
          onTap: () => _navigateToPaymentDetailView(context, apartment),
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
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('${apartment.attendantName} - דירה'),
          ),
          body: AttendantPaymentsView(payments: apartment.payments),
        ),
      ),
    );
    if (result == true) {
      _onPaymentReported();
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
            buildingId: _building.id,
            onExpenseAdded: () {
              _onPaymentReported();
            },
          ),
          AllPaymentsView(building: _building),
          AddApartmentDialog(
              buildingId: _building.id,
              onAdd: (Apartment newApartment) async {
                await _apartmentService.addApartment(newApartment);
                _building.apartments.add(newApartment);
                setState(() {});
              }),
          EditApartmentDialog(
            apartments: _building.apartments,
            onApartmentsUpdated: (List<Apartment> updatedApartments) async {
              _building.apartments = updatedApartments;
              await _buildingService.updateBuilding(_building);
              setState(() {});
            },
          ),
          ReportGeneratorButton(),
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
