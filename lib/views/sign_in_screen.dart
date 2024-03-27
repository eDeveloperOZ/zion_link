import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zion_link/views/dashboard_screen.dart';
import 'package:zion_link/core/services/sign_in_service.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailOrUsernameController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SignInService _signInService = SignInService();

  void _signIn() async {
    final email = _emailOrUsernameController.text;
    final password = _passwordController.text;
    final signInSuccess = await _signInService.signIn(email, password);

    if (signInSuccess) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashboardScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sign-in failed'),
        backgroundColor: Colors.red,
      ));
    }
  }

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
        title: Text('התחברות למערכת'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _emailOrUsernameController,
                decoration: InputDecoration(
                  labelText: 'שם משתמש',
                  hintText: 'הזן את שם המשתמש שלך',
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'סיסמה',
                  hintText: 'הזן את סיסמתך',
                ),
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _signIn,
                child: Text('כניסה'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 36),
                ),
              ),
              TextButton(
                onPressed: _showSignUpAlert,
                child: Text('הרשמה'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
