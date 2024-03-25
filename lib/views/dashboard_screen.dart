import 'package:flutter/material.dart';
import 'package:zion_link/core/models/building.dart';
import 'package:zion_link/features/buildings/add_building_view.dart';
import 'package:zion_link/views/building_details_screen.dart';
import 'package:zion_link/core/services/crud/building_service.dart';
import 'package:zion_link/views/setting_view.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Building> _localBuildings = [];
  final BuildingService _buildingService = BuildingService();

  @override
  void initState() {
    super.initState();
    _loadBuildings();
  }

  Future<void> _loadBuildings() async {
    List<Building> buildingsFromFile =
        await _buildingService.readAllBuildings();
    setState(() {
      _localBuildings = buildingsFromFile;
    });
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
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BuildingsDetailsScreen(building: building),
              ),
            );
            if (result == true) {
              _loadBuildings();
            }
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
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Stack(
        children: <Widget>[
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
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton.extended(
              onPressed: () async {
                final newBuilding = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBuildingView(
                      addBuildingCallback: _loadBuildings,
                    ),
                  ),
                );
                if (newBuilding is Building) {
                  await _buildingService.createBuilding(newBuilding);
                  await _loadBuildings();
                }
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
