import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tachles/core/models/user.dart';
import 'package:tachles/core/services/crud/apartment_service.dart';
import 'package:tachles/core/services/crud/user_service.dart';
import 'package:tachles/shared/widgets/category_dropdown.dart';
import 'package:tachles/shared/widgets/apartment_dropdown.dart';
import 'package:tachles/shared/widgets/error_message_widget.dart';
import 'package:tachles/shared/widgets/success_message_widget.dart';

class CreateUserDialog extends StatefulWidget {
  final UserType role;
  final String buildingId;
  final bool? isProfessionRequired;
  final String? apartmentSelectedId;

  CreateUserDialog(
      {Key? key,
      required this.role,
      required this.buildingId,
      this.isProfessionRequired,
      this.apartmentSelectedId})
      : super(key: key);

  @override
  _CreateUserDialogState createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  UserType? serviceProviderType;
  late String id;
  late String apartmentId;
  late String firstName;
  late String lastName;
  late String email;
  late String phoneNumber;
  late UserType role;
  late String profession;
  late String profilePictureUrl;
  late DateTime? dateOfBirth;
  late bool isProfessionRequired;
  late bool apartmentEmpty;

  @override
  void initState() {
    super.initState();
    id = UniqueKey().toString();
    apartmentId = widget.apartmentSelectedId ?? '';
    firstName = '';
    lastName = '';
    email = '';
    phoneNumber = '';
    profession = '';
    profilePictureUrl = '';
    dateOfBirth = null;
    isProfessionRequired = false;
    apartmentEmpty = false;
    role = widget.role;
    if (widget.role == UserType.routineServiceProvider ||
        widget.role == UserType.onCallServiceProvider) {
      isProfessionRequired = true;
    }
  }

  void _saveUser() async {
    if (apartmentEmpty) {
      User newUser = User.empty(
        id: UniqueKey().toString(), // Ensure a unique ID
        firstName: ' דירה',
        lastName: 'ריקה',
        email: '${UniqueKey().toString()}@empty.com',
        role: widget.role,
        phoneNumber: '0000000000',
      );
      try {
        await UserService.createUser(newUser, widget.buildingId);
        ScaffoldMessenger.of(context).showSnackBar(
          SuccessMessageWidget.create(message: 'הדירה ריקה נוצרה בהצלחה!'),
        );
        Navigator.pop(context, newUser);
      } catch (e) {
        // Catch any errors and display them
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorMessageWidget.create(
            message: 'אופס! נראה שיש בעיה ביצירת המשתמש: $e',
          ),
        );
      }
    } else {
      // Make the function async
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        if (isProfessionRequired)
          // set apartmentId to the first apartment in the building
          apartmentId = apartmentId.isEmpty
              ? (await ApartmentService()
                      .readAllApartmentsForBuilding(widget.buildingId))[0]
                  .id
              : apartmentId;

        if (!isProfessionRequired && dateOfBirth == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorMessageWidget.create(
              message: 'איך נדע מתי לאחל לך יומולדת שמח?',
            ),
          );
          return;
        }
        User newUser = User(
          id: id,
          apartmentId: apartmentId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          role: widget.role,
          profession: profession,
          profilePictureUrl: '', // TODO: set profilePictureUrl,
          dateOfBirth: dateOfBirth,
          createdAt: DateTime.now(),
        );

        try {
          await UserService.createUser(newUser, widget.buildingId);
          ScaffoldMessenger.of(context).showSnackBar(
            SuccessMessageWidget.create(
                message: 'איזה כיף לצרף את ${newUser.firstName} למשפחה!'),
          );
          Navigator.pop(context, newUser);
        } catch (e) {
          // Catch any errors and display them
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorMessageWidget.create(
              message: 'אופס! נראה שיש בעיה ביצירת המשתמש: $e',
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('כאן מספרים לנו על חבר חדש במשפחה!'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildNameFields(),
            _buildContactFields(),
            _buildProfessionFields(),
            _buildProfilePictureField(),
            _buildDateOfBirthField(),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameFields() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'שם פרטי'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'מה עם השם הפרטי?? איך נדע איך לפנות אל המשתמש?';
            }
            return null;
          },
          onSaved: (value) => firstName = value!,
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'שם משפחה'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'אויש! כנראה שכחת את שם המשפחה (או שרק שכחת להזין)';
            }
            return null;
          },
          onSaved: (value) => lastName = value!,
        ),
      ],
    );
  }

  Widget _buildContactFields() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'אימייל'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'לרוב, נעדיף לשלוח הודעות דרך המייל, נשמח שתשתפו אותנו :)';
            }
            return null;
          },
          onSaved: (value) => email = value!,
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'מספר טלפון'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'אנחנו נצטרך את מספר הטלפון על מנת שנוכל ליצור קשר :)';
            }
            return null;
          },
          onSaved: (value) => phoneNumber = value!,
        ),
        Center(
          child: Visibility(
            visible: !isProfessionRequired,
            child: Row(
              children: [
                Expanded(
                  child: ApartmentDropdown(
                    selectedApartmentId:
                        widget.apartmentSelectedId ?? apartmentId,
                    buildingId: widget.buildingId,
                    onApartmentChanged: (String? newApartmentId) {
                      setState(() {
                        apartmentId = newApartmentId!;
                      });
                    },
                  ),
                ),
                Visibility(
                  visible: role == UserType.tenant,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 140, // Set a maximum width for the checkbox
                    ),
                    child: CheckboxListTile(
                      title: Text('אף אחד'),
                      value: apartmentEmpty,
                      onChanged: (bool? value) {
                        setState(() {
                          apartmentEmpty = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionFields() {
    if (!isProfessionRequired) return Container();
    return Column(
      children: <Widget>[
        CategoryDropdown(
          isUtility: false,
          selectedCategory: profession,
          onSelectCategory: (String? newValue) {
            setState(() {
              profession = newValue!;
            });
          },
        ),
        ListTile(
          title: const Text('איש מקצוע קבוע'),
          leading: Radio<UserType>(
            value: UserType.routineServiceProvider,
            groupValue: serviceProviderType,
            onChanged: (UserType? value) {
              setState(() {
                serviceProviderType = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('איש מקצוע חד פעמי'),
          leading: Radio<UserType>(
            value: UserType.onCallServiceProvider,
            groupValue: serviceProviderType,
            onChanged: (UserType? value) {
              setState(() {
                serviceProviderType = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePictureField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'הזן לינק לתמונת פרופיל'),
      onSaved: (value) => profilePictureUrl = value!,
    );
  }

  Widget _buildDateOfBirthField() {
    return ListTile(
      title: Text('תאריך לידה'),
      subtitle:
          Text('${dateOfBirth?.toLocal().toString().split(' ')[0] ?? ''}'),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: dateOfBirth,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != dateOfBirth && !isProfessionRequired)
          setState(() {
            if (DateTime.now().difference(picked).inDays < 6570) {
              ScaffoldMessenger.of(context).showSnackBar(
                ErrorMessageWidget.create(
                  message: 'גיל המשתמש חייב להיות גדול מ-18 שנים',
                ),
              );
              return;
            } else {
              dateOfBirth = picked;
            }
          });
      },
    );
  }

  Widget _buildSaveButton() {
    return TextButton(
      onPressed: _saveUser,
      child: Text('שמור'),
    );
  }
}
