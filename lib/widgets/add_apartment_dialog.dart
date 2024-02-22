import 'package:flutter/material.dart';
import '../../../models/apartment.dart';

class AddApartmentDialog extends StatefulWidget {
  final Function(Apartment) onAdd;

  const AddApartmentDialog({Key? key, required this.onAdd}) : super(key: key);

  @override
  _AddApartmentDialogState createState() => _AddApartmentDialogState();
}

class _AddApartmentDialogState extends State<AddApartmentDialog> {
  final TextEditingController _attendantNameController =
      TextEditingController();
  final TextEditingController _yearlyPaymentAmountController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAddIconButton(context),
        Text('הוסף דירה חדשה'), // Text under the icon
      ],
    );
  }

  Widget _buildAddIconButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add, size: 24),
      onPressed: () => _onAddButtonPressed(context),
    );
  }

  Future<void> _onAddButtonPressed(BuildContext context) async {
    final Apartment? newApartment = await _showAddApartmentDialog(context);
    if (newApartment != null) {
      widget.onAdd(newApartment);
    }
  }

  Future<Apartment?> _showAddApartmentDialog(BuildContext context) {
    return showDialog<Apartment>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('הוסף דירה חדשה'),
          content: _buildDialogContent(),
          actions: _buildDialogActions(context),
        );
      },
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
    final Apartment newApartment = Apartment(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Unique ID based on timestamp
      attendantName: attendantName,
      yearlyPaymentAmount: yearlyPaymentAmount,
      payments: [],
    );
    Navigator.of(context).pop(newApartment);
  }
}
