import 'package:flutter/material.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/core/services/crud/apartment_service.dart';
import 'package:zion_link/shared/widgets/apartment_dropdown.dart'; // Import the new widget

class EditApartmentDialog extends StatefulWidget {
  // TODO: remove from the tree if not used by any other widgets
  final List<Apartment> apartments;
  final String updatedApartmentId;
  final Function(List<Apartment>) onApartmentsUpdated;

  EditApartmentDialog({
    Key? key,
    this.updatedApartmentId = '',
    required this.apartments,
    required this.onApartmentsUpdated,
  }) : super(key: key);

  @override
  _EditApartmentDialogState createState() => _EditApartmentDialogState();
}

class _EditApartmentDialogState extends State<EditApartmentDialog> {
  late String _localUpdatedApartmentId;
  final TextEditingController _attendantNameController =
      TextEditingController();
  final TextEditingController _yearlyPaymentAmountController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _localUpdatedApartmentId = widget.updatedApartmentId;
    if (widget.apartments.isNotEmpty) {
      _attendantNameController.text = widget.apartments[0].attendantName;
      _yearlyPaymentAmountController.text =
          widget.apartments[0].yearlyPaymentAmount.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, size: 24),
          onPressed: () {
            showDialog(
              context: context,
              builder: (builderContext) {
                return _editDialog(builderContext);
              },
            );
          },
        ),
        Text('ערוך פרטי דירה'),
      ],
    );
  }

  Widget _editDialog(BuildContext context) {
    return AlertDialog(
      title: Text('ערוך פרטי דירה'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ApartmentDropdown(
            apartments: widget.apartments,
            selectedApartmentId: _localUpdatedApartmentId,
            onApartmentChanged: (String? newValue) {
              final selectedApartment = widget.apartments
                  .firstWhere((apartment) => apartment.id == newValue);
              setState(() {
                _localUpdatedApartmentId = selectedApartment.id;
                _attendantNameController.text = selectedApartment.attendantName;
              });
            },
          ),
          TextField(
            controller: _attendantNameController,
            decoration: InputDecoration(hintText: "שם הדייר"),
          ),
          TextField(
            controller: _yearlyPaymentAmountController,
            decoration: InputDecoration(hintText: "סכום תשלום שנתי"),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('ביטול'),
        ),
        TextButton(
          onPressed: () {
            _saveChanges();
            Navigator.of(context).pop();
          },
          child: Text('שמור שינויים'),
        ),
      ],
    );
  }

  void _saveChanges() async {
    // Find the apartment to update in the list using its ID
    int indexToUpdate = widget.apartments
        .indexWhere((apartment) => apartment.id == _localUpdatedApartmentId);
    if (indexToUpdate != -1) {
      final String attendantName = _attendantNameController.text;
      final double yearlyPaymentAmount =
          double.tryParse(_yearlyPaymentAmountController.text) ?? 0.0;

      // Create an updated apartment instance
      Apartment updatedApartment = Apartment(
        id: widget.apartments[indexToUpdate].id,
        buildingId: widget.apartments[indexToUpdate].buildingId,
        number: widget.apartments[indexToUpdate].number,
        ownerName: widget.apartments[indexToUpdate].ownerName,
        attendantName: attendantName,
        yearlyPaymentAmount: yearlyPaymentAmount,
        pastDebt: widget.apartments[indexToUpdate].pastDebt,
      );

      // Update the apartment in the list
      List<Apartment> updatedApartments = List.from(widget.apartments);
      updatedApartments[indexToUpdate] = updatedApartment;

      // Use ApartmentService to update the apartment in the backend/database if necessary
      await ApartmentService().updateApartment(updatedApartment);

      // Call the onApartmentsUpdated callback with the updated list of apartments
      widget.onApartmentsUpdated(updatedApartments);
    }
  }
}
