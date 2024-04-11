import 'package:flutter/material.dart';
import 'package:tachles/core/models/user.dart';
import 'package:tachles/core/services/crud/user_service.dart';
import 'package:tachles/shared/widgets/category_dropdown.dart';
import 'package:tachles/shared/widgets/apartment_dropdown.dart';
import 'package:tachles/shared/widgets/success_message_widget.dart';
import 'package:tachles/shared/widgets/error_message_widget.dart';

/// Dialog for editing user details.
///
/// This dialog allows editing various details of a [User], including name, email,
/// phone number, profession, and more. It uses form validation to ensure the data
/// integrity before saving.
class EditUserDialog extends StatefulWidget {
  final User user;
  final String buildingId;

  const EditUserDialog({Key? key, required this.user, required this.buildingId})
      : super(key: key);

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _firstName;
  late String _lastName;
  late String? _apartmentId;
  late String _email;
  late String _phone;
  late String? _profession;
  late String? _profilePictureUrl;
  late DateTime? _dateOfBirth;
  late DateTime _updatedAt;

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
  }

  /// Loads initial values from the user object into the form fields.
  void _loadInitialValues() {
    _firstName = widget.user.firstName;
    _lastName = widget.user.lastName ?? '';
    _email = widget.user.email;
    _phone = widget.user.phoneNumber ?? '';
    _profilePictureUrl = widget.user.profilePictureUrl;
    _dateOfBirth = widget.user.dateOfBirth;
    _updatedAt = widget.user.updatedOn ?? DateTime.now();

    if (widget.user.role == UserType.owner ||
        widget.user.role == UserType.tenant) {
      _apartmentId = widget.user.apartmentId;
      _profession = null;
    }
    if (widget.user.role == UserType.routineServiceProvider ||
        widget.user.role == UserType.onCallServiceProvider) {
      _profession = widget.user.profession;
      _apartmentId = null;
    }
  }

  /// Updates the user details based on the form input.
  void _updateUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Update the user object with new values
      widget.user
        ..firstName = _firstName
        ..lastName = _lastName
        ..email = _email
        ..phoneNumber = _phone
        ..profession = _profession
        ..profilePictureUrl = _profilePictureUrl
        ..dateOfBirth = _dateOfBirth
        ..apartmentId = _apartmentId
        ..updatedOn = DateTime.now();

      try {
        await UserService().updateUser(widget.user);
        ScaffoldMessenger.of(context).showSnackBar(
          SuccessMessageWidget.create(
            message: 'משתמש עודכן בהצלחה',
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorMessageWidget.create(
            message: '$e אירעה בעת עריכת המשתמש',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('ערוך משתמש'),
      content: Form(
        key: _formKey,
        child: _buildFormContent(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('ביטול'),
        ),
        ElevatedButton(
          onPressed: _updateUser,
          child: Text('שמור'),
        ),
      ],
    );
  }

  /// Builds the content of the form including all form fields.
  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextFormField(
          initialValue: _firstName,
          decoration: InputDecoration(labelText: 'שם פרטי'),
          onSaved: (value) => _firstName = value!,
          validator: (value) => value!.isEmpty ? 'אנא הכנס שם פרטי' : null,
        ),
        TextFormField(
          initialValue: _lastName,
          decoration: InputDecoration(labelText: 'שם משפחה'),
          onSaved: (value) => _lastName = value!,
        ),
        TextFormField(
          initialValue: _email,
          decoration: InputDecoration(labelText: 'אימייל'),
          onSaved: (value) => _email = value!,
          validator: (value) => value!.isEmpty ? 'אנא הכנס אימייל' : null,
        ),
        TextFormField(
          initialValue: _phone,
          decoration: InputDecoration(labelText: 'מספר טלפון'),
          onSaved: (value) => _phone = value!,
          validator: (value) => value!.isEmpty ? 'אנא הכנס מספר טלפון' : null,
        ),
        TextFormField(
          initialValue: _profilePictureUrl,
          decoration: InputDecoration(labelText: 'תמונת פרופיל'),
          onSaved: (value) => _profilePictureUrl = value!,
        ),
        _buildDateOfBirthField(),
        if (widget.user.role == UserType.routineServiceProvider ||
            widget.user.role == UserType.onCallServiceProvider)
          CategoryDropdown(
            isUtility: false,
            onSelectCategory: (category) => _profession = category,
          ),
        if (widget.user.role == UserType.owner ||
            widget.user.role == UserType.tenant)
          ApartmentDropdown(
            buildingId: widget.buildingId,
            selectedApartmentId: _apartmentId,
            onApartmentChanged: (apartment) => _apartmentId = apartment,
          ),
      ],
    );
  }

  /// Builds the date of birth selection field with validation for age.
  Widget _buildDateOfBirthField() {
    return ListTile(
      title: Text('תאריך לידה'),
      subtitle: Text('${_dateOfBirth?.toLocal() ?? ''}'),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _dateOfBirth) {
          setState(() {
            if (DateTime.now().difference(picked).inDays < 6570) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('גיל המשתמש חייב להיות גדול מ-18 שנים'),
                ),
              );
              return;
            } else {
              _dateOfBirth = picked;
            }
          });
        }
      },
    );
  }
}
