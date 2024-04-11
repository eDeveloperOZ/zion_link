import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tachles/core/services/crud/user_service.dart';
import 'package:tachles/views/dashboard_screen.dart';
import 'package:tachles/core/services/sign_in_service.dart';
import 'package:tachles/core/models/user.dart' as tachles;
import 'package:tachles/shared/widgets/error_message_widget.dart';

enum UserType {
  admin,
  owner,
  management,
  tenant,
  routineServiceProvider,
  onCallServiceProvider
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Added form key for validation
  final UserService _userService = UserService();
  final TextEditingController _emailOrUsernameController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SignInService _signInService = SignInService();
  bool _isLoading = false; // Loading state

  void _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return; // If the form is not valid, do nothing
    }
    setState(() => _isLoading = true);

    final email = _emailOrUsernameController.text.trim();
    final password = _passwordController.text.trim();
    try {
      final signInSuccess = await _signInService.signIn(email, password);
      if (signInSuccess) {
        final userExists = await _userService
            .getUserById(Supabase.instance.client.auth.currentUser!.id);
        if (userExists == null) {
          tachles.User user = tachles.User.empty(
            id: Supabase.instance.client.auth.currentUser!.id,
            email: email,
            role: tachles.UserType.management,
            buildingId: "",
          );
          await UserService.createUser(user, "");
        }
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            ErrorMessageWidget.create(message: 'Incorrect email or password.'));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An unexpected error occurred'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/logo.png',
                  height: 400,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(height: 32),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: TextFormField(
                    controller: _emailOrUsernameController,
                    decoration: InputDecoration(
                      labelText: 'שם משתמש',
                      hintText: 'הזן את שם המשתמש שלך',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => value!.isEmpty
                        ? 'מייל זה חובה.. אחרת איך נדע מי אתה?'
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'סיסמה',
                      hintText: 'הזן את סיסמתך',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) => value!.isEmpty || value.length < 6
                        ? 'איזו דרמה! שכחת סיסמא'
                        : null,
                  ),
                ),
                SizedBox(height: 32),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('כניסה'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                  'ת׳כלס היא פלטפורמה בהקמה ואנחנו כאן כדי לשמוע את דעתכם ולשפר את המוצר שלנו. נשמח (מאוד!) לשמוע מכם על הדברים שאתם חושבים שצריך לשפר, אנחנו עובדים כל הזמן להוסיף לכם עוד כלים ואפשרויות. עד אז אתם מוזמנים לעיין באפשרויות שכבר קיימות',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                FeatureUpdatesWidget(),
                SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.facebook, color: Colors.white),
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
                    label: Text('דברו איתנו בפייסבוק',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}

class FeatureUpdatesWidget extends StatefulWidget {
  @override
  _FeatureUpdatesWidgetState createState() => _FeatureUpdatesWidgetState();
}

class _FeatureUpdatesWidgetState extends State<FeatureUpdatesWidget> {
  // Define filter options
  final List<String> filterOptions = ['הכל', 'הושלם', 'בתהליך'];
  String selectedFilter = 'הכל';

  // Example data for completed and upcoming features
  final List<String> completedFeatures = [
    "עיצוב דף בית חדש",
    "שליחת הודעות על איחור בתשלום",
    "שׁליחת הודעה לדיירים מתוך המערכת",
    "שליחת מיילים לדיירים",
    "עידכון על דירה פנויה",
    "חיזוי תשלומים של  הדירה",
    "הזנת דוח תשלום עבור תקופה נתונה",
    "תמיכה ביתרת הבניין",
    "מעבר לגרסה אינטרנטית!!",
    "התראה על פרטי דייר ובעלים שחסרים",
    "חלון תשלומים שמציג לפי קטגוריות ",
    "קידוד השתלומים לפי צבעים לאיחור/דרוש אישור/מאושר",
    "הזנת הוצאה עבור ספקים",
  ];
  final List<String> upcomingFeatures = [
    "התאמת תצוגה לכלל המכשירים",
    "הוספת עוד פרטים על הבניין",
    "פונקציית תזכורות על תשלומים/תחזוקה וכו׳",
    "הוספת פרטי דיירים בצורה מרוכזת",
    "תהליך אונבורדינג לדייר חדש",
    "תמיכה בבניינים שיש להם שתי כתובות (בניין פינתי וכד׳)",
    "תמיכה בחניות",
    "תמיכה במחסנים במידה ותיהיה דרישה ממשתמשים",
    "אפשרות תצוגה לדיירים",
    "תמיכה בדירות שותפים",
    "אוטומציות אוטומציות אוטומציות",
  ];

  @override
  Widget build(BuildContext context) {
    List<Widget> filteredFeatures = [];

    // Determine which features to show based on the selected filter
    if (selectedFilter == 'הכל') {
      // Combine and shuffle the lists for a random mix
      List<String> combinedFeatures = List.from(completedFeatures)
        ..addAll(upcomingFeatures);
      combinedFeatures.shuffle();
      filteredFeatures.addAll(combinedFeatures.map((feature) {
        // Use a simple heuristic to determine if a feature is completed or upcoming based on which list it came from
        TextStyle style = completedFeatures.contains(feature)
            ? TextStyle(color: Colors.green)
            : TextStyle(color: Colors.red);
        return Text(feature, style: style);
      }));
    } else if (selectedFilter == 'הושלם') {
      filteredFeatures.addAll(completedFeatures.map(
          (feature) => Text(feature, style: TextStyle(color: Colors.green))));
    } else if (selectedFilter == 'בתהליך') {
      filteredFeatures.addAll(upcomingFeatures.map(
          (feature) => Text(feature, style: TextStyle(color: Colors.red))));
    }

    return Column(
      children: [
        // Filter buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: filterOptions
              .map((option) => ElevatedButton(
                    onPressed: () => setState(() => selectedFilter = option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedFilter == option ? Colors.blue : Colors.grey,
                    ),
                    child: Text(option),
                  ))
              .toList(),
        ),
        SizedBox(height: 10),
        // Wrap the SingleChildScrollView with a Scrollbar
        Scrollbar(
          thumbVisibility:
              true, // Ensures the scrollbar thumb is always visible on desktop & web
          child: Container(
            height: 200, // Set a fixed height for the container
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: filteredFeatures,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
