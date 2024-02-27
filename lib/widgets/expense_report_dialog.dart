import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'category_dropdown.dart';
import 'upload_document_button.dart';
import 'all_expenses_button.dart'; // Import the AllExpenses widget

class ExpenseReportDialog extends StatefulWidget {
  final List<Expense> expenses;
  final String buildingId;
  final Function
      onDialogOpened; // This callback function will be used to update the expenses

  const ExpenseReportDialog(
      {Key? key,
      required this.expenses,
      required this.buildingId,
      required this.onDialogOpened}) // Ensure this is passed in the constructor
      : super(key: key);

  @override
  _ExpenseReportDialogState createState() => _ExpenseReportDialogState();
}

class _ExpenseReportDialogState extends State<ExpenseReportDialog> {
  List<Expense> expenses = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    ExpenseService expenseService = ExpenseService();
    List<Expense> loadedExpenses =
        await expenseService.fetchExpenses(widget.buildingId);
    setState(() {
      expenses = loadedExpenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit_note, size: 24),
          onPressed: () async {
            print('Before showDialog - selectedCategory: $selectedCategory');
            await widget
                .onDialogOpened(); // Call the onDialogOpened callback here
            await showExpenseReportDialog(context, expenses, widget.buildingId,
                _loadExpenses, selectedCategory, (String? newCategory) {
              setState(() {
                selectedCategory = newCategory;
                print(
                    'Inside showDialog callback - selectedCategory updated to: $selectedCategory');
              });
            });
            print('After showDialog - selectedCategory: $selectedCategory');
            // After the dialog is closed, you might want to refresh the expenses again
            // to ensure any changes made in the dialog are reflected.
            await _loadExpenses();
          },
        ),
        Text('דיווח הוצאה'),
      ],
    );
  }
}

Future<String?> showExpenseReportDialog(
    BuildContext context,
    List<Expense> expenses,
    String buildingId,
    Future<void> Function() onExpensesUpdated,
    String? selectedCategory, // Accept selectedCategory as a parameter
    Function(String?)
        onSelectCategory // Callback to update selectedCategory in the parent state
    ) async {
  String currentBuildingId = buildingId;
  List<String> categories = [
    'חשמלאי',
    'מים',
    'ארנונה',
    'גינון',
    'אינסטלטור',
    'אחר...',
  ];
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      final TextEditingController amountController = TextEditingController();
      final TextEditingController noteController = TextEditingController();
      String? filePath; // Define filePath here
      DateTime selectedDate = DateTime.now();

      return AlertDialog(
        title: Text('דיווח הוצאות'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AllExpensesButton(
                  expenses: expenses,
                  buildingId: currentBuildingId,
                  onExpensesUpdated: onExpensesUpdated,
                ),
                CategoryDropdown(
                  categories: categories,
                  selectedCategory: selectedCategory,
                  onSelectCategory: onSelectCategory,
                ),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'סכום',
                  ),
                ),
                UploadDocumentButton(
                  onFilePicked: (String? path) {
                    setState(() {
                      filePath = path;
                    });
                  },
                ),
                TextFormField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'הערה',
                  ),
                ),
                Text('מספר ההוצאות: ${expenses.length}'),
                ElevatedButton(
                  onPressed: () async {
                    final double amount =
                        double.tryParse(amountController.text) ?? 0.0;
                    final String note = noteController.text;
                    final Expense newExpense = Expense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: note,
                      amount: amount,
                      date: selectedDate,
                      categoryId: selectedCategory ?? 'אחר',
                      filePath: filePath,
                    );
                    print('newExpense.categoryId: ${newExpense.categoryId}');
                    ExpenseService expenseService = ExpenseService();
                    await expenseService.addExpense(
                        currentBuildingId, newExpense);
                    setState(() {});
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('שלח'),
                ),
              ],
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Center(child: Text('ביטול')),
          ),
        ],
      );
    },
  );
  return selectedCategory; // Add this line before closing the dialog
}
