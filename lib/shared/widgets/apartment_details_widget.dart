import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tachles/core/models/apartment.dart';
import 'package:tachles/core/models/user.dart';
import 'package:tachles/shared/widgets/notifier_widget.dart';

class ApartmentDetailsWidget extends StatelessWidget {
  final Apartment apartment;
  final User? tenant;
  final User? owner;
  final Function(BuildContext, User?) onUserTap;

  const ApartmentDetailsWidget({
    Key? key,
    required this.apartment,
    required this.tenant,
    required this.owner,
    required this.onUserTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                'דירה ${apartment.number}',
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(width: 8),
              _buildUserDetails(context, 'משכיר', tenant, onUserTap),
              SizedBox(width: 8),
              _buildUserDetails(context, 'בעלים', owner, onUserTap),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetails(
    BuildContext context,
    String label,
    User? user,
    Function(BuildContext, User?) onUserTap,
  ) {
    return Tooltip(
      message: 'ערוך פרטי $label',
      child: user == null || (user.id.isEmpty && user.role == UserType.tenant)
          ? GestureDetector(
              onTap: () => onUserTap(context, user),
              child: Text(
                ' הזן פרטי $label',
                style: TextStyle(fontSize: 25),
              ),
            )
          : GestureDetector(
              onTap: () => onUserTap(context, user),
              child: _buildUserDetailsWidget(user),
            ),
    );
  }

  Widget _buildUserDetailsWidget(User user) {
    return Row(
      children: [
        Text(user.firstName),
        GestureDetector(
          onTap: () {
            final phoneLaunchUri = Uri(
              scheme: 'tel',
              path: user.phoneNumber,
            );
            launchUrl(phoneLaunchUri);
          },
          child: Tooltip(
            message: user.phoneNumber ?? 'לא קיים מספר טלפון',
            child: Icon(Icons.phone),
          ),
        ),
        GestureDetector(
          onTap: () {
            final emailLaunchUri = Uri(
              scheme: 'mailto',
              path: user.email,
            );
            launchUrl(emailLaunchUri);
          },
          child: Tooltip(
            message: user.email,
            child: Icon(Icons.mail),
          ),
        ),
        NotifierWidget(
          message: '',
          phoneNumber: user.phoneNumber ?? '',
          tooltip: 'שלח הודעה',
        ),
      ],
    );
  }
}
