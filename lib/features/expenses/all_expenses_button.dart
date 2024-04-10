import 'package:flutter/material.dart';
import 'package:tachles/features/expenses/all_expenses_view.dart';

/// A widget that, when tapped, navigates to the AllExpensesView.
///
/// This button is intended to be used within the BuildingDetailsScreen to allow
/// users to view all expenses related to a specific building. It requires the
/// buildingId to fetch and display the relevant expenses.
///
/// Parameters:
///   - buildingId: A [String] representing the unique identifier of the building
///     whose expenses are to be displayed.
///
/// Usage:
/// ```dart
/// AllExpenseButton(buildingId: 'your-building-id')
/// ```
class AllExpensesButton extends StatelessWidget {
  final String buildingId;

  const AllExpensesButton({Key? key, required this.buildingId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          icon: const Icon(Icons.show_chart, size: 24),
          onPressed: () => _navigateToAllExpensesView(context, buildingId),
        ),
        Text(' כל ההוצאות'),
      ],
    );
  }

  /// Navigates to the AllExpensesView, passing the buildingId.
  ///
  /// This method is triggered when the button is tapped. It uses the Navigator
  /// to push the AllExpensesView onto the navigation stack, ensuring that the
  /// user can return to the previous screen.
  ///
  /// Parameters:
  ///   - context: The build context from which the navigation is initiated.
  ///   - buildingId: The buildingId to be passed to the AllExpensesView.
  void _navigateToAllExpensesView(BuildContext context, String buildingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllExpensesView(buildingId: buildingId),
      ),
    );
  }
}
