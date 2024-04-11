import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tachles/core/models/building.dart';
import 'package:tachles/core/models/user.dart' as zion;
import 'package:tachles/core/models/user_building_association.dart';
import 'package:tachles/core/services/crud/user_service.dart';
import 'package:tachles/core/services/crud/user_building_association_service.dart';
import 'package:tachles/features/buildings/add_building_view.dart';
import 'package:tachles/views/building_details_screen.dart';
import 'package:tachles/core/services/crud/building_service.dart';
import 'package:tachles/views/setting_view.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Building> _localBuildings = [];
  final BuildingService _buildingService = BuildingService();
  final UserService _userService = UserService();
  final UserBuildingAssociationService _userBuildingAssociationService =
      UserBuildingAssociationService();
  zion.User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadBuildings();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    currentUser = await _userService
        .getUserById(Supabase.instance.client.auth.currentUser!.id);
  }

  Future<void> _loadBuildings() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    List<Building> buildings = [];
    List<UserBuildingAssociation> associations =
        await _userBuildingAssociationService.getAssociationsByUserId(userId);
    if (associations.isEmpty) {
      setState(() {
        _localBuildings = buildings;
      });
      return;
    }
    for (var association in associations) {
      final building =
          await _buildingService.getBuildingById(association.buildingId);
      if (building != null) {
        buildings.add(building);
      }
    }
    setState(() {
      _localBuildings = buildings;
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
          Visibility(
            // Only allow to non-company users to create more then one building
            visible: (_localBuildings.length < 5 &&
                    (currentUser?.role == zion.UserType.company) ||
                (_localBuildings.length < 1 &&
                    currentUser?.role == zion.UserType.management)),
            child: Align(
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
                    await _buildingService.createBuilding(
                        newBuilding, currentUser!.id);
                    await _loadBuildings();
                  }
                },
                heroTag: 'addBuildingButton',
                icon: Icon(Icons.add),
                label: Text('הוסף בניין'),
                backgroundColor: Colors.green,
              ),
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
        title: Text('ת׳כלס - עושים עבורך את העבודה המיותרת!'),
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
