import 'package:flutter/material.dart';
import 'package:zion_link/core/models/expense.dart';
import 'package:zion_link/core/services/storage_service.dart';
import 'package:zion_link/shared/widgets/confirm_dialog_widget.dart';
import 'package:zion_link/core/services/crud/expense_service.dart'; // Import ExpenseService

class EditExpenseView extends StatefulWidget {
  final Expense expense;
  final String buildingId;

  const EditExpenseView(
      {Key? key, required this.expense, required this.buildingId})
      : super(key: key);

  @override
  _EditExpenseViewState createState() => _EditExpenseViewState();
}

class _EditExpenseViewState extends State<EditExpenseView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  List<String> _categories = [
    'חשמלאי',
    'מים',
    'ארנונה',
    'תחזוקת מעליות',
    'גינון',
    'אינסטלטור',
    'אחר...'
  ];

  final ExpenseService _expenseService = ExpenseService(); // Add this line

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _noteController = TextEditingController(text: widget.expense.title);
    _selectedCategory = widget.expense.categoryId;
    _selectedDate = widget.expense.date;

    // Add the category if it's not in the list
    if (_selectedCategory != null && !_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory!);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateExpense() async {
    if (_formKey.currentState!.validate()) {
      // Assuming an updateExpense method is defined in a suitable class
      await StorageService.updateExpense(
        widget.expense.copyWith(
          amount: double.parse(_amountController.text),
          title: _noteController.text,
          categoryId: _selectedCategory!,
          date: _selectedDate,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteExpense() async {
    final confirmDelete = await ConfirmDialog.display(
      context,
      message: 'האם אתה בטוח שברצונך למחוק הוצאה זו?',
      onConfirm: (bool isConfirmed) {
        Navigator.of(context).pop(isConfirmed);
      },
    );

    if (confirmDelete == true) {
      // Use ExpenseService to delete the expense
      await _expenseService.deleteExpense(widget.expense.id);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('עריכת הוצאה'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'סכום'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'אנא הזן סכום';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'הערה'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'קטגוריה'),
            ),
            ElevatedButton(
              onPressed: _updateExpense,
              child: Text('שמור'),
            ),
            ElevatedButton(
              onPressed: _deleteExpense,
              child: Text('מחק'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set the background color to red
              ),
            ),
          ],
        ),
      ),
    );
  }
}
