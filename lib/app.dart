import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'views/dashboard_view.dart';
import 'views/signin_view.dart'; // Import the SigninView

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        locale: Locale('he', 'IL'),
        supportedLocales: [
          Locale('he', 'IL'), // Hebrew
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: 'ISR_homes',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // Set the initial route to SigninView
        home:
            SigninView(), // Change this to use SigninView as the initial screen
        routes: {
          '/dashboard': (context) => DashboardView(
                buildings: [],
                userId: '<userIdValue>',
              ), // Define the route for DashboardView
        },
      ), // Close the MaterialApp widget
    ); // Close the Directionality widget
  }
}
