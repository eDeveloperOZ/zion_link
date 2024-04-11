import 'package:flutter/material.dart';
import 'package:tachles/core/models/building.dart';
import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/core/models/user.dart';
import 'package:tachles/core/services/crud/apartment_service.dart';
import 'package:tachles/core/services/crud/user_service.dart';
import 'package:tachles/features/payments/apartment_payments_view.dart';

class AllPaymentsView extends StatefulWidget {
  final Building building;

  const AllPaymentsView({Key? key, required this.building}) : super(key: key);

  @override
  _AllPaymentsViewState createState() => _AllPaymentsViewState();
}

class _AllPaymentsViewState extends State<AllPaymentsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          icon: const Icon(Icons.manage_accounts, size: 24),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BuildingPaymentsView(building: widget.building),
              ),
            );
          },
        ),
        Text(' כל התשלומים'),
      ],
    );
  }
}

class BuildingPaymentsView extends StatefulWidget {
  final Building building;

  const BuildingPaymentsView({Key? key, required this.building})
      : super(key: key);

  @override
  _BuildingPaymentsViewState createState() => _BuildingPaymentsViewState();
}

class _BuildingPaymentsViewState extends State<BuildingPaymentsView> {
  Apartment? selectedApartment;
  String? selectedFilter = 'all';
  UserService userService = UserService();

  Widget _buildFilterDropdown() {
    return BottomNavigationBar(
      currentIndex: _getSelectedFilterIndex(),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Tooltip(
            message: "All payments",
            child: Icon(Icons.money),
          ),
          label: 'כל התשלומים',
        ),
        BottomNavigationBarItem(
          icon: Tooltip(
            message:
                "Payments that the tenant has not yet transferred but is expected to transfer",
            child: Icon(Icons.query_stats),
          ),
          label: 'חיזוי תשלומים',
        ),
        BottomNavigationBarItem(
          icon: Tooltip(
            message: "Payments made by the tenant",
            child: Icon(Icons.check),
          ),
          label: 'תשלומים שבוצעו',
        ),
        BottomNavigationBarItem(
          icon: Tooltip(
            message:
                "Payments whose date is from the past in relation to the present",
            child: Icon(Icons.history),
          ),
          label: 'תשלומים שעברו',
        ),
        BottomNavigationBarItem(
          icon: Tooltip(
            message: "All approved payments",
            child: Icon(Icons.verified),
          ),
          label: 'תשלומים מאושרים',
        ),
        BottomNavigationBarItem(
          icon: Tooltip(
            message:
                "Payments that should have been transferred and were not transferred",
            child: Icon(Icons.warning),
          ),
          label: 'תשלומים באיחור',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() {
          switch (index) {
            case 0:
              selectedFilter = 'all';
              break;
            case 1:
              selectedFilter = 'prediction';
              break;
            case 2:
              selectedFilter = 'made';
              break;
            case 3:
              selectedFilter = 'past';
              break;
            case 4:
              selectedFilter = 'approved';
              break;
            case 5:
              selectedFilter = 'overdue';
              break;
            default:
              selectedFilter = null;
          }
        });
      },
    );
  }

  int _getSelectedFilterIndex() {
    switch (selectedFilter) {
      case 'all':
        return 0;
      case 'prediction':
        return 1;
      case 'made':
        return 2;
      case 'past':
        return 3;
      case 'approved':
        return 4;
      case 'overdue':
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    ApartmentService apartmentService = ApartmentService();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.building.name} - תשלומים'),
      ),
      body: FutureBuilder(
        future: Future.wait([
          apartmentService.readAllApartmentsForBuilding(widget.building.id),
          userService.readAllUsersForBuilding(widget.building.id)
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Apartment> apartments = snapshot.data![0] as List<Apartment>;
            List<User> users = snapshot.data![1] as List<User>;
            return ListView.builder(
              itemCount: apartments.length,
              itemBuilder: (context, index) {
                final apartment = apartments[index];
                final tenant = users.firstWhere(
                    (user) => user.id == apartment.tenantId,
                    orElse: () => User.empty());
                return ExpansionTile(
                  title: Text('דירה ${apartment.number} - ${tenant.firstName}'),
                  children: [
                    ApartmentPaymentsView(
                      apartment: apartment,
                      selectedFilter: selectedFilter,
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: _buildFilterDropdown(),
    );
  }
}
