// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:zion_link/views/dashboard_view.dart';

// class SignInScreen extends StatefulWidget {
//   @override
//   _SignInScreenState createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   final TextEditingController _emailOrUsernameController =
//       TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   final SupabaseClient _supabaseClient = Supabase.instance.client;

//   void _signIn() async {
//     final email = _emailOrUsernameController.text;
//     final password = _passwordController.text;

//     try {
//       final response = await _supabaseClient.auth
//           .signInWithPassword(email: email, password: password);
//       if (response.user != null) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Sign-in successful!'),
//           backgroundColor: Colors.green,
//         ));
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (context) =>
//                     DashboardView(userId: response.user!.id, buildings: [])));
//         // This line of code navigates the user to the dashboard screen upon successful sign-in.
//         // It replaces the current route in the navigator's stack, ensuring that the user cannot navigate back to the sign-in screen using the back button.
//         // Now, it also passes the user ID to the DashboardView.
//       }
//     } on AuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Sign-in failed: ${e.message}'),
//         backgroundColor: Colors.red,
//       ));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('An unexpected error occurred'),
//         backgroundColor: Colors.red,
//       ));
//     }
//   }

//   void _showSignUpAlert() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('שלום'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text('איזה כיף שהגעת אלינו'),
//                 Text(
//                     'צור איתנו קשר! נשמח לשמוע על הצרכים של הבניין שלכם ולצרף אתכן חינם אופיר: 0528389127'),
//                 InkWell(
//                   child: Text('לפייסבוק https://www.facebook.com/ofir.ozery/',
//                       style: TextStyle(color: Colors.blue)),
//                   onTap: () async {
//                     final url =
//                         Uri.parse('https://www.facebook.com/ofir.ozery/');
//                     if (await canLaunchUrl(url)) {
//                       await launchUrl(url);
//                     } else {
//                       throw 'Could not launch $url';
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('סגור'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('התחברות למערכת'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               TextField(
//                 controller: _emailOrUsernameController,
//                 decoration: InputDecoration(
//                   labelText: 'שם משתמש',
//                   hintText: 'הזן את שם המשתמש שלך',
//                 ),
//               ),
//               SizedBox(height: 8),
//               TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'סיסמה',
//                   hintText: 'הזן את סיסמתך',
//                 ),
//                 obscureText: true,
//               ),
//               SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _signIn,
//                 child: Text('כניסה'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 36),
//                 ),
//               ),
//               TextButton(
//                 onPressed: _showSignUpAlert,
//                 child: Text('הרשמה'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
