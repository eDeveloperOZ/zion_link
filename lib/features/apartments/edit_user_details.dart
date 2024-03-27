import 'package:flutter/material.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';
import 'package:zion_link/shared/widgets/error_message_widget.dart';

class EditUserDetails extends StatefulWidget {
  final String buildingId;

  const EditUserDetails({
    Key? key,
    required this.buildingId,
  }) : super(key: key);

  @override
  _EditUserDetailsState createState() => _EditUserDetailsState();
}

class _EditUserDetailsState extends State<EditUserDetails> {
  final ApartmentService _apartmentService = ApartmentService();

  void _showApartmentSelectionDialog(BuildContext context) async {
    final List<Apartment> apartments =
        await _apartmentService.readAllApartmentsForBuilding(widget.buildingId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Apartment'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: apartments.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(apartments[index].tenantId),
                  onTap: () =>
                      _showEditApartmentDialog(context, apartments[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showEditApartmentDialog(BuildContext context, Apartment apartment) {
    final TextEditingController _tenantNameController =
        TextEditingController(text: apartment.tenantId);
    final TextEditingController _yearlyPaymentAmountController =
        TextEditingController(text: apartment.yearlyPaymentAmount.toString());
    // Add other controllers for each field

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Apartment Details'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _tenantNameController,
                  decoration: InputDecoration(labelText: "Tenant Name"),
                ),
                TextField(
                  controller: _yearlyPaymentAmountController,
                  decoration:
                      InputDecoration(labelText: "Yearly Payment Amount"),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                // Add other TextFields for each editable field
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update the apartment object with new values
                apartment.tenantId = _tenantNameController.text;
                apartment.yearlyPaymentAmount =
                    double.tryParse(_yearlyPaymentAmountController.text) ??
                        apartment.yearlyPaymentAmount;
                // Update other fields similarly

                // Save the updated apartment
                _apartmentService.updateApartment(apartment).then((_) {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Apartment details updated successfully')),
                  );
                }).catchError((error) {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    ErrorMessageWidget.create(
                        message: 'Error updating apartment details'),
                  );
                });
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _showApartmentSelectionDialog(context),
        ),
        Text('ערוך פרטי משתמשים'),
      ],
    );
  }
}
