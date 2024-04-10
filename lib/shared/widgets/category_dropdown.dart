import 'package:flutter/material.dart';

class CategoryDropdown extends StatelessWidget {
  final List<String>? categories;
  final String? selectedCategory;
  final bool isUtility;
  final Function(String?) onSelectCategory;

  final List<String> serviceProviders = ['חשמלאי', 'אינסטלטור', 'אחר...'];
  final List<String> utilities = ['מים', 'ארנונה', 'אחר...'];

  CategoryDropdown({
    Key? key,
    this.categories,
    this.selectedCategory,
    required this.onSelectCategory,
    required this.isUtility,
  }) : super(key: key) {
    if (categories != null) {
      if (isUtility) {
        utilities.addAll(categories!);
      } else {
        serviceProviders.addAll(categories!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final actualCategories = isUtility ? utilities : serviceProviders;

    final actualValue =
        actualCategories.contains(selectedCategory) ? selectedCategory : null;

    return DropdownButtonFormField<String>(
      value: actualValue,
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
              onSelectCategory(value);
            }
          });
        } else {
          onSelectCategory(newValue);
        }
      },
      items: actualCategories.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
