import 'package:armando2/home_page.dart';
import 'package:armando2/signin_page.dart';
import 'package:armando2/signup_dart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/homepage': (context) => HomePage(),
      },
    );
  }
}