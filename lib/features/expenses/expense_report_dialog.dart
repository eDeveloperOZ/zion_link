import 'package:flutter/material.dart';
import 'package:zion_link/core/models/expense.dart';
import 'package:zion_link/core/services/crud/expense_service.dart';
import 'package:zion_link/shared/widgets/category_dropdown.dart';
import 'package:zion_link/shared/widgets/upload_document_button.dart';
import 'package:zion_link/features/expenses/expense_report_button.dart'; // Import the AllExpenses widget

class ExpenseReportDialog extends StatefulWidget {
  final String buildingId;
  final Function onExpenseAdded;

  ExpenseReportDialog({
    Key? key,
    required this.buildingId,
    required this.onExpenseAdded, // Require the callback in the constructor
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
        await expenseService.readAllExpensesForBuilding(widget.buildingId);
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
        ExpenseReportButton(
          expenses: _expenses,
          buildingId: widget.buildingId,
          onExpensesUpdated: () {
            setState(() {
              // Update logic here, if any
            });
          }, // Pass the method here
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
        onPressed: () {
          _submitExpenseReport(context);
          setState(() {
            _amountController.clear();
            _noteController.clear();
            _selectedCategory = null;
            _filePath = null;
          });
        },
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
    await expenseService.createExpense(newExpense);

    widget.onExpenseAdded(newExpense);
    setState(() {
      _expenses.add(newExpense);
    });
    Navigator.of(context).pop(); // Close the dialog
  }
}
