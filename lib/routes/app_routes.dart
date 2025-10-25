import 'package:flutter/material.dart';
import '../views/login_view.dart';
import '../views/home_view.dart';
import '../views/search_view.dart';
import '../views/create_request_view.dart';

/// Centralized route management for the app
/// Makes navigation easier and more maintainable
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String search = '/search';
  static const String createRequest = '/create-request';

  /// Generate routes based on route name
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeView());

      case search:
        return MaterialPageRoute(builder: (_) => const SearchView());

      case createRequest:
        return MaterialPageRoute(builder: (_) => const CreateRequestView());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('الصفحة غير موجودة: ${settings.name}')),
          ),
        );
    }
  }
}

