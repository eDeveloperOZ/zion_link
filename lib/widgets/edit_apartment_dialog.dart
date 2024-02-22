import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../services/apartment_service.dart'; // Added import for ApartmentService

class EditApartmentDialog extends StatefulWidget {
  final String updatedApartmentId; // Removed the final keyword
  final List<Apartment> apartments;
  final Function(List<Apartment>) onApartmentsUpdated;

  EditApartmentDialog({
    Key? key,
    this.updatedApartmentId = '', // Default value provided
    required this.apartments,
    required this.onApartmentsUpdated,
  }) : super(key: key);

  @override
  _EditApartmentDialogState createState() => _EditApartmentDialogState();
}

class _EditApartmentDialogState extends State<EditApartmentDialog> {
  late String _localUpdatedApartmentId; // Marked as late
  final TextEditingController _attendantNameController =
      TextEditingController();
  final TextEditingController _yearlyPaymentAmountController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _localUpdatedApartmentId =
        widget.updatedApartmentId; // Initialize with the widget's initial value
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
        _buildEditIconButton(context),
        Text('ערוך פרטי דירה'),
      ],
    );
  }

  Widget _buildEditIconButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit, size: 24),
      onPressed: () => _showEditDialog(context),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final Apartment? editedApartment = await showDialog<Apartment>(
      context: context,
      builder: (BuildContext context) => _buildEditDialog(context),
    );

    if (editedApartment != null) {
      widget.onApartmentsUpdated([editedApartment]);
    }
  }

  Widget _buildEditDialog(BuildContext context) {
    return AlertDialog(
      title: Text('ערוך פרטי דירה'),
      content: _buildDialogContent(),
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

  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildApartmentDropdown(),
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
    );
  }

  Widget _buildApartmentDropdown() {
    return DropdownButton<String>(
      value: _localUpdatedApartmentId.isNotEmpty
          ? widget.apartments
              .firstWhere(
                  (apartment) => apartment.id == _localUpdatedApartmentId)
              .attendantName
          : null,
      onChanged: (String? newValue) {
        final selectedApartment = widget.apartments
            .firstWhere((apartment) => apartment.attendantName == newValue);
        setState(() {
          _localUpdatedApartmentId = selectedApartment.id;
          _attendantNameController.text = newValue!;
        });
      },
      hint: Text("בחר דייר"),
      items: widget.apartments
          .map<DropdownMenuItem<String>>((Apartment apartment) {
        return DropdownMenuItem<String>(
          value: apartment.attendantName,
          child: Text(apartment.attendantName),
        );
      }).toList(),
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
        attendantName: attendantName,
        yearlyPaymentAmount: yearlyPaymentAmount,
        payments: widget.apartments[indexToUpdate].payments,
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
