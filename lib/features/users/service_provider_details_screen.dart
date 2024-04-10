import 'package:flutter/material.dart';
import 'package:tachles/core/models/user.dart';
import 'package:tachles/core/services/crud/user_service.dart';
import 'package:tachles/features/users/create_user_dialog.dart';
import 'package:tachles/features/users/edit_user_dialog.dart';

/// A widget for displaying and editing service provider details within a building context.
///
/// This screen allows users to view a list of service providers associated with a specific building,
/// edit their details, or add new service providers. It utilizes [UserService] to fetch and manage
/// user data, and integrates with [CreateUserDialog] and [EditUserDialog] for creating and editing
/// service provider records.
///
/// The widget is compatible across iOS, Android, PC, macOS, and web platforms.
class ServiceProviderDetailsScreen extends StatefulWidget {
  final String buildingId;

  /// Constructs a [ServiceProviderDetailsScreen] widget.
  ///
  /// Requires a [buildingId] to fetch service providers associated with the specified building.
  const ServiceProviderDetailsScreen({
    Key? key,
    required this.buildingId,
  }) : super(key: key);

  @override
  _ServiceProviderDetailsScreenState createState() =>
      _ServiceProviderDetailsScreenState();
}

class _ServiceProviderDetailsScreenState
    extends State<ServiceProviderDetailsScreen> {
  /// Builds the view for displaying service providers.
  ///
  /// Utilizes a [FutureBuilder] to asynchronously fetch service provider data
  /// and display it in a list. Each list item can be tapped to edit the service
  /// provider's details using [EditUserDialog]. A button is provided at the bottom
  /// to add a new service provider via [CreateUserDialog].
  Widget _buildServiceProvidersView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ספקי שירותים'),
      ),
      body: FutureBuilder<List<User?>>(
        future:
            UserService().getAllServiceProvidersForBuliding(widget.buildingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final serviceProviders = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: serviceProviders.length,
                    itemBuilder: (context, index) {
                      final serviceProvider = serviceProviders[index];
                      return ListTile(
                        title: Text(serviceProvider!.firstName),
                        subtitle: Text(serviceProvider.email),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => EditUserDialog(
                              user: serviceProvider,
                              buildingId: widget.buildingId,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('הוסף ספק שירותים חדש'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateUserDialog(
                                role: UserType.routineServiceProvider,
                                buildingId: widget.buildingId)),
                      ).then((newUser) {
                        setState(() {});
                      });
                    },
                  ),
                ),
              ],
            );
          }
          return Center(child: Text('אין ספקים להצגה'));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => _buildServiceProvidersView(context)),
          ),
        ),
        Text(' ערוך פרטי ספקים'),
      ],
    );
  }
}
