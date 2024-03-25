import 'package:flutter/material.dart';
import 'package:zion_link/core/models/apartment.dart';
import 'package:zion_link/shared/widgets/error_message_widget.dart';

class AddApartmentDialog extends StatefulWidget {
  final String buildingId;
  final Function(Apartment) onAdd;

  const AddApartmentDialog({
    Key? key,
    required this.onAdd,
    required this.buildingId,
  }) : super(key: key);

  @override
  _AddApartmentDialogState createState() => _AddApartmentDialogState();
}

class _AddApartmentDialogState extends State<AddApartmentDialog> {
  final TextEditingController _attendantNameController =
      TextEditingController();
  final TextEditingController _yearlyPaymentAmountController =
      TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.add, size: 24),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorMessageWidget.create(
                message:
                    'כפתור לא בשימוש ברגע זה', // This button is not in use at the moment in Hebrew
              ),
            );
          },
        ),
        Text('ערוך פרטי דירה'), // Text under the icon
      ],
    );
  }

  Widget _addApartmentDialog(BuildContext context) {
    return AlertDialog(
      title: Text('הוסף דירה חדשה'),
      content: _buildDialogContent(),
      actions: _buildDialogActions(context),
    );
  }

  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
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

  List<Widget> _buildDialogActions(BuildContext context) {
    return <Widget>[
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('ביטול'),
      ),
      TextButton(
        onPressed: () => _addApartment(context),
        child: Text('הוסף'),
      ),
    ];
  }

  void _addApartment(BuildContext context) {
    final String attendantName = _attendantNameController.text;
    final double yearlyPaymentAmount =
        double.tryParse(_yearlyPaymentAmountController.text) ?? 0.0;
    final String ownerName = _ownerNameController.text;
    final String number = _numberController.text;
    final Apartment newApartment = Apartment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      buildingId: widget.buildingId,
      number: number,
      ownerName: ownerName,
      attendantName: attendantName,
      yearlyPaymentAmount: yearlyPaymentAmount,
      pastDebt: 0,
    );

    // Call the onAdd callback with the newApartment
    widget.onAdd(newApartment);

    // Then close the dialog
    Navigator.of(context).pop();
  }
}
