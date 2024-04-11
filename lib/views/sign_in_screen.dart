import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tachles/core/services/crud/user_service.dart';
import 'package:tachles/views/dashboard_screen.dart';
import 'package:tachles/core/services/sign_in_service.dart';
import 'package:tachles/core/models/user.dart' as tachles;
// import 'package:tachles/core/utils/logger.dart';
import 'package:tachles/shared/widgets/error_message_widget.dart';

enum UserType {
  admin,
  owner,
  management,
  tenant,
  routineServiceProvider,
  onCallServiceProvider
}

/// SignInScreen provides a UI for users to sign in.
///
/// It includes text fields for entering username and password, and buttons for sign in and registration.
/// Upon successful sign in, it navigates to the DashboardView.
class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final UserService _userService = UserService();
  final TextEditingController _emailOrUsernameController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SignInService _signInService = SignInService();

  /// Attempts to sign in the user using the provided email and password.
  ///
  /// On success, navigates to the DashboardView. On failure, displays an error message.
  void _signIn() async {
    final email = _emailOrUsernameController.text;
    final password = _passwordController.text;
    try {
      final signInSuccess = await _signInService.signIn(email, password);
      if (signInSuccess) {
        final userExists = await _userService
            .getUserById(Supabase.instance.client.auth.currentUser!.id);
        if (userExists == null) {
          // create a new user

          tachles.User user = tachles.User.empty(
            id: Supabase.instance.client.auth.currentUser!.id,
            email: email,
            role: tachles.UserType.management,
            buildingId: "",
          );
          await UserService.createUser(user, "");
        }
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DashboardScreen())); // Navigate to DashboardView
      } else {
        ScaffoldMessenger.of(context).showSnackBar(ErrorMessageWidget.create(
          message: 'יש מצב שהסיסמא שגויה? דבר איתנו אם ניסית כמה וכמה פעמים',
        ));
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sign-in failed: ${e.message}'),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An unexpected error occurred'),
        backgroundColor: Colors.red,
      ));
    }
  }

  /// Displays a sign-up alert dialog with contact information.
  void _showSignUpAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('שלום'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('איזה כיף שהגעת אלינו'),
                Text(
                    'צור איתנו קשר! נשמח לשמוע על הצרכים של הבניין שלכם ולצרף אתכן חינם אופיר: 0528389127'),
                InkWell(
                  child: Text('לפייסבוק https://www.facebook.com/ofir.ozery/',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () async {
                    final url =
                        Uri.parse('https://www.facebook.com/ofir.ozery/');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('סגור'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ברוכים הבאים ל-Tachles!'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo.png',
                height: 400,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(height: 32),
              TextField(
                controller: _emailOrUsernameController,
                decoration: InputDecoration(
                  labelText: 'שם משתמש',
                  hintText: 'הזן את שם המשתמש שלך',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'סיסמה',
                  hintText: 'הזן את סיסמתך',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _signIn,
                child: Text('כניסה'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: _showSignUpAlert,
                child: Text('הרשמה'),
              ),
              SizedBox(height: 32),
              Text(
                'אנחנו כאן כדי לשמוע את דעתכם ולשפר את השירות שלנו. נשמח לשמוע מכם על הדברים שאתם חושבים שצריך לשפר, ואנחנו עובדים כל הזמן להוסיף לכם עוד כלים ואפשרויות. אתם מוזמנים לעיין באפשרויות שכבר קיימות',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  const url = 'https://www.facebook.com/ofir.ozery/';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cannot open Facebook profile.'),
                      ),
                    );
                  }
                },
                child: Text('דברו איתנו בפייסבוק'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String message;
  final bool IsDone;

  const MessageWidget({Key? key, required this.message, required this.IsDone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          message,
          style: TextStyle(
            color: IsDone ? Colors.green : Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
