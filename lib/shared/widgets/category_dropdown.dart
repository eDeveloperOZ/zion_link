import 'package:flutter/material.dart';

class CategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onSelectCategory;

  const CategoryDropdown({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      hint: Text('בחר קטגוריה'),
      onChanged: (String? newValue) {
        print('Dropdown onChanged - newValue: $newValue');
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
              print('After custom category dialog - selectedCategory: $value');
            }
          });
        } else {
          print(
              'Inside Dropdown onChanged - selectedCategory updated to: $newValue');
          onSelectCategory(newValue);
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
}
