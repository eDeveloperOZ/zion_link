import 'package:flutter/material.dart';
import '../models/building.dart'; // Adjust the import path as necessary
import 'add_building_view.dart'; // Adjust the import path as necessary
import 'building_list_view.dart'; // Adjust the import path as necessary
import '../services/building_service.dart'; // Adjust the import path as necessary
import '../widgets/success_message_widget.dart'; // Import the success message widget
import 'setting_view.dart'; // Import the SettingView widget

class DashboardView extends StatefulWidget {
  final List<Building> buildings;

  DashboardView({required this.buildings});

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<Building> _localBuildings = []; // Local list to manage buildings

  @override
  void initState() {
    super.initState();
    _loadBuildings();
  }

  void _loadBuildings() async {
    List<Building> buildingsFromFile = await BuildingService().fetchBuildings();
    if (buildingsFromFile.isNotEmpty) {
      setState(() {
        _localBuildings.addAll(buildingsFromFile);
      });
    }
  }

  void reloadBuildings() async {
    List<Building> buildingsFromFile = await BuildingService().fetchBuildings();
    setState(() {
      _localBuildings.clear();
      _localBuildings.addAll(buildingsFromFile);
    });
  }

  void updateBuilding(Building updatedBuilding) async {
    await BuildingService().updateBuilding(updatedBuilding);
    reloadBuildings(); // Refresh the buildings list
  }

  Future<void> addBuilding(Building newBuilding) async {
    try {
      await BuildingService().addBuilding(newBuilding);
      reloadBuildings();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: SuccessMessageWidget(message: 'הבניין נוסף בהצלחה'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('נכשל בהוספת בניין: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _localBuildings.length,
      itemBuilder: (context, index) {
        final building = _localBuildings[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BuildingDetailView(
                      building: building,
                      onBuildingDeleted: reloadBuildings,
                      onBuildingUpdated: updateBuilding)),
            ).then((_) => reloadBuildings());
          },
          child: SizedBox(
            height: 100,
            child: Card(
              elevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.lightBlueAccent,
              child: Center(
                child: ListTile(
                  title: Text(building.name, textAlign: TextAlign.center),
                  subtitle: Text(building.address, textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0), // Adjust padding as needed
      child: Stack(
        children: <Widget>[
          // Settings Button aligned to the left
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingView(),
                    ),
                  );
                },
                heroTag: 'settingsButton',
                child: Icon(Icons.settings),
                backgroundColor: Colors.grey,
              ),
            ),
          ),
          // Centered Add Building Button
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBuildingView(
                        addBuildingCallback: (newBuilding) async {
                      await addBuilding(newBuilding); // Use addBuilding method
                    }),
                  ),
                ).then((value) {
                  if (value == true) {
                    setState(() {}); // Refresh the state if needed
                  }
                });
              },
              heroTag: 'addBuildingButton',
              icon: Icon(Icons.add),
              label: Text('הוסף בניין'),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('בניין עולם'),
        backgroundColor: Colors.green,
      ),
      body: _localBuildings.isNotEmpty
          ? _buildGridView()
          : Center(child: Text('לא נוספו בניינים')),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
