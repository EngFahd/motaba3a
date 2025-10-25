import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics Service
/// Tracks user events and app usage
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the analytics observer for navigation tracking
  FirebaseAnalyticsObserver get analyticsObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log a custom event
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      // Fail silently for analytics errors
      debugPrint('Analytics error: $e');
    }
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log login event
  Future<void> logLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log sign up event
  Future<void> logSignUp(String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log search event
  Future<void> logSearch(String searchTerm) async {
    try {
      await _analytics.logSearch(searchTerm: searchTerm);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Set user properties
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Set user ID
  Future<void> setUserId(String id) async {
    try {
      await _analytics.setUserId(id: id);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log app open event
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // ========== Custom Events for Motaba3a App ==========

  /// Log service request created
  Future<void> logServiceRequestCreated({
    required String vehicleType,
    required double price,
  }) async {
    await logEvent(
      name: 'service_request_created',
      parameters: {
        'vehicle_type': vehicleType,
        'price': price,
      },
    );
  }

  /// Log service request completed
  Future<void> logServiceRequestCompleted({
    required String requestId,
    required int durationDays,
  }) async {
    await logEvent(
      name: 'service_request_completed',
      parameters: {
        'request_id': requestId,
        'duration_days': durationDays,
      },
    );
  }

  /// Log client search
  Future<void> logClientSearch(String phoneNumber) async {
    await logEvent(
      name: 'client_search',
      parameters: {
        'search_type': 'phone',
      },
    );
  }
}

