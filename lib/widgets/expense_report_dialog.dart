import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../views/attendant_expenses_view.dart';

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
  String? selectedCategory; // Moved to a higher scope

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
            await widget
                .onDialogOpened(); // Call the onDialogOpened callback here
            await showExpenseReportDialog(context, expenses, widget.buildingId,
                _loadExpenses, selectedCategory, (String? newCategory) {
              setState(() {
                selectedCategory = newCategory;
              });
            });
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

class ExpenseSummary extends StatelessWidget {
  final List<Expense> expenses;
  final String buildingId;
  final Future<void> Function() onExpensesUpdated;

  const ExpenseSummary({
    Key? key,
    required this.expenses,
    required this.buildingId,
    required this.onExpensesUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'כל התשלומים',
      child: GestureDetector(
        onTap: () async {
          final result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AttendantExpensesView(
                buildingId: buildingId,
              );
            },
          );
          if (result == true) {
            await onExpensesUpdated(); // Use the callback here
          }
          // Trigger state update in parent widget if needed
        },
        child:
            Text('סך ההוצאות: ₪${expenses.fold(0.0, (a, b) => a + b.amount)}'),
      ),
    );
  }
}

Widget _buildCategoryDropdown({
  required List<String> categories,
  required String? selectedCategory,
  required StateSetter setState,
  required BuildContext context,
  required Function(String?) onSelectCategory,
}) {
  return DropdownButtonFormField<String>(
    value: selectedCategory,
    hint: Text('בחר קטגוריה'),
    onChanged: (String? newValue) {
      if (newValue == 'אחר...') {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('הזן את הקטגוריה'),
              content: TextField(
                autofocus: true,
                onSubmitted: (String value) {
                  Navigator.pop(context, value);
                },
              ),
            );
          },
        ).then((String? value) {
          if (value != null) {
            setState(() {
              categories.add(value);
              selectedCategory = value;
            });
            onSelectCategory(value); // Use the callback to update
          }
        });
      } else {
        onSelectCategory(newValue); // Use the callback to update
      }
    },
    items: categories.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
  );
}

Widget _buildUploadDocumentButton({
  required StateSetter setState,
  required String? filePath,
}) {
  return TextButton.icon(
    icon: Icon(Icons.upload_file),
    label: Text('העלאת מסמך'),
    onPressed: () async {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          filePath = result.files.single.path;
        });
      } else {
        // User canceled the picker or the operation failed
      }
    },
  );
}

Future<void> showExpenseReportDialog(
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
    'תחזוקת מעליות',
    'גינון',
    'אינסטלטור',
    'אחר...',
  ]; // Example categories
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
                ExpenseSummary(
                  expenses: expenses,
                  buildingId: currentBuildingId,
                  onExpensesUpdated: onExpensesUpdated,
                ),
                _buildCategoryDropdown(
                  categories: categories,
                  selectedCategory: selectedCategory,
                  setState: setState,
                  context: context,
                  onSelectCategory: onSelectCategory,
                ),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'סכום',
                  ),
                ),
                _buildUploadDocumentButton(
                    setState: setState, filePath: filePath),
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
                      categoryId: selectedCategory ??
                          'אחר', // Default to 'Other' if no category selected
                      filePath: filePath,
                    );
                    ExpenseService expenseService = ExpenseService();
                    await expenseService.addExpense(
                        currentBuildingId, newExpense);
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
}
