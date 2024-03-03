import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'category_dropdown.dart';
import 'upload_document_button.dart';
import 'all_expenses_button.dart'; // Import the AllExpenses widget

class ExpenseReportDialog extends StatefulWidget {
  final String buildingId;

  ExpenseReportDialog({
    Key? key,
    required this.buildingId,
  }) : super(key: key);

  @override
  _ExpenseReportDialogState createState() => _ExpenseReportDialogState();
}

class _ExpenseReportDialogState extends State<ExpenseReportDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _selectedCategory;
  String? _filePath;
  DateTime _selectedDate = DateTime.now();
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() async {
    ExpenseService expenseService = ExpenseService();
    List<Expense> loadedExpenses =
        await expenseService.getAllExpensesForBuilding(widget.buildingId);
    setState(() {
      _expenses = loadedExpenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit_note, size: 24),
          onPressed: () {
            showDialog(
              context: context,
              builder: (builderContext) {
                return _expenseReportDialog(builderContext);
              },
            );
          },
        ),
        Text('דיווח הוצאה'),
      ],
    );
  }

  Widget _expenseReportDialog(BuildContext context) {
    return AlertDialog(
      title: Text('דיווח הוצאות'),
      content: _buildDialogContent(),
      actions: _buildDialogActions(context),
    );
  }

  Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AllExpensesButton(
          expenses: _expenses,
          buildingId: widget.buildingId,
        ),
        CategoryDropdown(
          categories: [
            'חשמלאי',
            'מים',
            'ארנונה',
            'גינון',
            'אינסטלטור',
            'אחר...'
          ],
          selectedCategory: _selectedCategory,
          onSelectCategory: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
        ),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'סכום',
          ),
        ),
        UploadDocumentButton(
          onFilePicked: (String? path) {
            setState(() {
              _filePath = path;
            });
          },
        ),
        TextFormField(
          controller: _noteController,
          decoration: InputDecoration(
            labelText: 'הערה',
          ),
        ),
        Text('מספר ההוצאות: ${_expenses.length}'),
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
        onPressed: () => _submitExpenseReport(context),
        child: Text('שלח'),
      ),
    ];
  }

  void _submitExpenseReport(BuildContext context) async {
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final String note = _noteController.text;
    final Expense newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      buildingId: widget.buildingId,
      title: note,
      amount: amount,
      date: _selectedDate,
      categoryId: _selectedCategory ?? 'אחר',
      filePath: _filePath,
    );

    ExpenseService expenseService = ExpenseService();
    await expenseService.addExpenseToBuilding(widget.buildingId, newExpense);
    Navigator.of(context).pop(); // Close the dialog
  }
}
