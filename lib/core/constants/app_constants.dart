import 'package:flutter/material.dart';

/// App-wide constants for colors, styles, and configuration
/// Centralized location for all constant values
class AppConstants {
  // ========== Colors ==========
  static const Color primaryBlue = Color(0xFF1455D4);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;

  // ========== Text Styles ==========
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  // ========== Spacing ==========
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // ========== Border Radius ==========
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // ========== Animation Durations ==========
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ========== App Configuration ==========
  static const String appName = 'متابعة';
  static const String appVersion = '1.0.0';
  static const int searchDebounceMs = 500;

  // ========== Firebase Collections ==========
  static const String usersCollection = 'users';
  static const String serviceRequestsCollection = 'service_requests';

  // ========== Asset Paths ==========
  // Add asset paths here when assets are added
  // static const String logoPath = 'assets/images/logo.png';
}

