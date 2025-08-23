import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

// Minimal auth stub for routing decisions only. Replace with Firebase later.
class AuthStub {
  // Toggle this to true to simulate an authenticated session.
  static bool get isLoggedIn => false;
}

class AppRouter {
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';

  static Map<String, WidgetBuilder> get routes => {
    '/': (context) => const HomeScreen(),
    home: (context) => const HomeScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
  };

  static String initialRoute() => AuthStub.isLoggedIn ? home : login;
}
