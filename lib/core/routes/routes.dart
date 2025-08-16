import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:trackai/features/analytics/analyticsscreen.dart';
import 'package:trackai/features/home/homepage.dart';
import 'package:trackai/features/home/homescreen.dart';
import 'package:trackai/features/auth/views/login_page.dart';
import 'package:trackai/features/settings/settingsscreen.dart';
import 'package:trackai/features/auth/views/signup_page.dart';
import 'package:trackai/features/tracker/trackerscreen.dart';

class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String homeScreen = '/home-screen';
  static const String trackerScreen = '/tracker-screen';
  static const String analyticsScreen = '/analytics-screen';
  static const String settingsScreen = '/settings-screen';

  // Initial route
  static const String initialRoute = login;

  // Generate routes
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _createRoute(const LoginPage());
      case signup:
        return _createRoute(const SignupPage());

      case home:
        return _createRoute(const HomePage());

      case homeScreen:
        return _createRoute(const Homescreen());

      case trackerScreen:
        return _createRoute(const Trackerscreen());

      case analyticsScreen:
        return _createRoute(const AnalyticsScreen());

      case settingsScreen:
        return _createRoute(const Settingsscreen());

      default:
        return _createRoute(
          Scaffold(
            body: Center(
              child: Text(
                'Route not found: ${settings.name}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        );
    }
  }

  static PageRoute _createRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
