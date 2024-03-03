// Importing necessary packages and files for the UI and functionality
import 'package:flutter/material.dart';
import 'package:zion_link/views/all_payments_view.dart';
import '../models/building.dart';
import '../models/apartment.dart';
import '../services/building_service.dart';
import '../services/apartment_service.dart';
import 'payments_detail_view.dart';
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
  late Building _building;
  final BuildingService _buildingService = BuildingService();
  final ApartmentService _apartmentService = ApartmentService();

  @override
  void initState() {
    super.initState();
    _building = widget.building;
  }

  void _onPaymentReported() async {
    Building updatedBuilding = await BuildingService()
        .getBuildingById(_building.id); // Use _building.id
    setState(() {
      _building = updatedBuilding;
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
            buildingId: _building.id,
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

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_building.name),
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
