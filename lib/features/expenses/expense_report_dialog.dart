import 'package:flutter/material.dart';
import 'package:tachles/core/models/expense.dart';
import 'package:tachles/core/models/user.dart';
import 'package:tachles/core/services/crud/expense_service.dart';
import 'package:tachles/core/services/crud/user_service.dart';
import 'package:tachles/shared/widgets/category_dropdown.dart';
import 'package:tachles/shared/widgets/upload_document_button.dart';
import 'package:tachles/features/expenses/expense_report_button.dart';
import 'package:tachles/features/users/create_user_dialog.dart';
import 'package:tachles/core/utils/logger.dart';

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
  final UserService _userService = UserService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _selectedCategory;
  String? _selectedServiceProvider;
  String? _filePath;
  DateTime _selectedDate = DateTime.now();
  List<Expense> _expenses = [];
  List<User?> _serviceProviders = [];
  bool _isUtility = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _updateSelectedServiceProvider(String? newValue) async {
    if (newValue != null && newValue != 'create_user') {
      User? user = await _userService.getUserById(newValue);
      if (user != null) {
        setState(() {
          _selectedServiceProvider = user.id;
        });
      }
    }
  }

  void _loadExpenses() async {
    try {
      ExpenseService expenseService = ExpenseService();
      List<Expense> loadedExpenses =
          await expenseService.readAllExpensesForBuilding(widget.buildingId);
      if (mounted) {
        setState(() {
          _expenses = loadedExpenses;
        });
      }
    } catch (e) {
      Logger.error('Error loading expenses: $e');
    }
  }

  Future<List<User?>> _loadServiceProviders(String profession) async {
    if (_isUtility) {
      return [];
    }
    try {
      UserService userService = UserService();
      List<User?> loadedServiceProviders = await userService
          .getAllServiceProvidersForBuliding(widget.buildingId);
      if (loadedServiceProviders.isEmpty) {
        // Show dialog to create a new user if no service providers are found
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('לא נמצאו נותני שירותים אצלכם בבניין עדיין'),
            content: Text('האם תרצו להוסיף נותן שירות חדש?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => CreateUserDialog(
                                role: UserType.routineServiceProvider,
                                buildingId: widget.buildingId,
                              )))
                      .then((value) => setState(() {}));
                },
                child: Text('בטח!'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('לא תודה'),
              ),
            ],
          ),
        );
      }
      return loadedServiceProviders;
    } catch (e) {
      Logger.error('Error loading service providers: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          icon: Icon(Icons.edit_note, size: 24),
          onPressed: () {
            showDialog(
              context: context,
              builder: (builderContext) {
                return StatefulBuilder(
                  builder: (stateContext, setState) {
                    return _expenseReportDialog(stateContext, setState);
                  },
                );
              },
            );
          },
        ),
        Text(' דיווח הוצאה'),
      ],
    );
  }

  Widget _buildServiceProviderDropdown() {
    return DropdownButton<String>(
      value: _selectedServiceProvider,
      hint: Text('בחר נותן שירות'),
      onChanged: (String? newValue) async {
        if (newValue == 'create_user') {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CreateUserDialog(
                    role: UserType.routineServiceProvider,
                    buildingId: widget.buildingId,
                  )));
        } else {
          await _updateSelectedServiceProvider(newValue);
        }
      },
      items: [
        ..._serviceProviders.map<DropdownMenuItem<String>>((User? user) {
          return DropdownMenuItem<String>(
            value: user?.id,
            child: Text('${user?.firstName} ${user?.lastName ?? ''}'),
          );
        }).toList(),
        DropdownMenuItem<String>(
          value: 'create_user',
          child: Text('הוסף נותן שירות חדש'),
        ),
      ],
    );
  }

  Widget _expenseReportDialog(BuildContext context, StateSetter setState) {
    return AlertDialog(
      title: Text('דיווח הוצאות'),
      content: _buildDialogContent(setState),
      actions: _buildDialogActions(context),
    );
  }

  Widget _buildDialogContent(StateSetter setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ExpenseReportButton(
          expenses: _expenses,
          buildingId: widget.buildingId,
          onExpensesUpdated: () {
            setState(() {});
          }, // Pass the method here
        ),
        Tooltip(
          message:
              'חשבון תשתיות הוא חשבון שמגיע עבור שירותי התשתית בבניין, כגון חשמל, מים וארנונה',
          child: CheckboxListTile(
            title: Text('חשבון תשתיות'),
            value: _isUtility,
            onChanged: (bool? newValue) {
              setState(() {
                _isUtility = newValue!;
              });
            },
          ),
        ),
        CategoryDropdown(
          isUtility: _isUtility,
          selectedCategory: _selectedCategory,
          onSelectCategory: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
              _selectedServiceProvider =
                  null; // Reset the selected service provider
              _serviceProviders = []; // Clear previous service providers
            });
            _loadServiceProviders(newValue!);
          },
        ),
        if (_selectedCategory != null && _isUtility == false)
          FutureBuilder<List<User?>>(
            future: _loadServiceProviders(_selectedCategory!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Text('לא נמצאו נותני שירותים אצלכם בבניין עדיין');
              } else {
                _serviceProviders = snapshot.data!;
                return _buildServiceProviderDropdown();
              }
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
            _selectedServiceProvider = null;
            _filePath = null;
            _isUtility = true;
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
        serviceProviderId: _selectedServiceProvider ?? '',
        isUtility: _isUtility,
        title: note,
        amount: amount,
        date: _selectedDate,
        categoryId: _selectedCategory ?? 'אחר',
        filePath: _filePath ?? "");

    ExpenseService expenseService = ExpenseService();
    await expenseService.createExpense(newExpense);

    widget.onExpenseAdded(newExpense);
    setState(() {
      _expenses.add(newExpense);
    });
    Navigator.of(context).pop(); // Close the dialog
  }
}
