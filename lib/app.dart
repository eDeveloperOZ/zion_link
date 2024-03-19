import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'views/dashboard_screen.dart';

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
        home: DashboardScreen(
          buildings: [],
        ), // Set the initial route or home screen
        // Define other routes here if necessary
      ), // Close the MaterialApp widget
    ); // Close the Directionality widget
  }
}
