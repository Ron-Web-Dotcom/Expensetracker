import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Analytics service for tracking user behavior and engagement metrics
/// Stores all data locally for privacy-first approach
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static const String _eventsKey = 'analytics_events';
  static const String _sessionKey = 'analytics_session';
  static const String _userMetricsKey = 'user_metrics';

  /// Track screen view
  Future<void> trackScreenView(String screenName) async {
    await _logEvent('screen_view', {
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track user action/event
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    await _logEvent(eventName, {
      ...?parameters,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track expense addition
  Future<void> trackExpenseAdded({
    required double amount,
    required String category,
    required String paymentMethod,
  }) async {
    await _logEvent('expense_added', {
      'amount': amount,
      'category': category,
      'payment_method': paymentMethod,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _updateUserMetrics('total_expenses_added', 1);
  }

  /// Track budget creation/update
  Future<void> trackBudgetAction(
    String action, {
    required String category,
    required double amount,
  }) async {
    await _logEvent('budget_$action', {
      'category': category,
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track feature usage
  Future<void> trackFeatureUsage(String featureName) async {
    await _logEvent('feature_used', {
      'feature': featureName,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _updateUserMetrics('feature_${featureName}_count', 1);
  }

  /// Track user engagement (session start)
  Future<void> trackSessionStart() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = {
      'session_id': DateTime.now().millisecondsSinceEpoch.toString(),
      'start_time': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_sessionKey, jsonEncode(sessionData));
    await _updateUserMetrics('total_sessions', 1);
  }

  /// Track user engagement (session end)
  Future<void> trackSessionEnd() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(_sessionKey);
    if (sessionJson != null) {
      final session = jsonDecode(sessionJson);
      final startTime = DateTime.parse(session['start_time']);
      final duration = DateTime.now().difference(startTime).inSeconds;

      await _logEvent('session_end', {
        'session_id': session['session_id'],
        'duration_seconds': duration,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await prefs.remove(_sessionKey);
    }
  }

  /// Track AI performance (categorization accuracy)
  Future<void> trackAICategorization({
    required String suggestedCategory,
    required String finalCategory,
    required bool wasAccepted,
  }) async {
    await _logEvent('ai_categorization', {
      'suggested': suggestedCategory,
      'final': finalCategory,
      'accepted': wasAccepted,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (wasAccepted) {
      await _updateUserMetrics('ai_correct_predictions', 1);
    }
    await _updateUserMetrics('ai_total_predictions', 1);
  }

  /// Track spending patterns
  Future<void> trackSpendingPattern(
    String pattern,
    Map<String, dynamic> data,
  ) async {
    await _logEvent('spending_pattern', {
      'pattern_type': pattern,
      ...data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get analytics summary
  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final metricsJson = prefs.getString(_userMetricsKey);

    if (metricsJson == null) {
      return {
        'total_sessions': 0,
        'total_expenses_added': 0,
        'ai_accuracy': 0.0,
        'most_used_features': [],
      };
    }

    final metrics = jsonDecode(metricsJson) as Map<String, dynamic>;

    // Calculate AI accuracy
    final aiCorrect = metrics['ai_correct_predictions'] ?? 0;
    final aiTotal = metrics['ai_total_predictions'] ?? 0;
    final aiAccuracy = aiTotal > 0 ? (aiCorrect / aiTotal * 100) : 0.0;

    return {
      'total_sessions': metrics['total_sessions'] ?? 0,
      'total_expenses_added': metrics['total_expenses_added'] ?? 0,
      'ai_accuracy': aiAccuracy,
      'metrics': metrics,
    };
  }

  /// Get recent analytics events
  Future<List<Map<String, dynamic>>> getRecentEvents({int limit = 50}) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_eventsKey);
    if (eventsJson == null) return [];

    try {
      final events = (jsonDecode(eventsJson) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      return events.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding analytics events: $e');
      }
      return [];
    }
  }

  /// Clear all analytics data
  Future<void> clearAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventsKey);
    await prefs.remove(_sessionKey);
    await prefs.remove(_userMetricsKey);
  }

  // Private helper methods
  Future<void> _logEvent(String eventName, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_eventsKey);

    List<Map<String, dynamic>> events = [];
    if (eventsJson != null) {
      events = (jsonDecode(eventsJson) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }

    events.insert(0, {'event_name': eventName, 'data': data});

    // Keep only last 1000 events
    if (events.length > 1000) {
      events = events.take(1000).toList();
    }

    await prefs.setString(_eventsKey, jsonEncode(events));
  }

  Future<void> _updateUserMetrics(String metricKey, int increment) async {
    final prefs = await SharedPreferences.getInstance();
    final metricsJson = prefs.getString(_userMetricsKey);

    Map<String, dynamic> metrics = {};
    if (metricsJson != null) {
      metrics = jsonDecode(metricsJson) as Map<String, dynamic>;
    }

    metrics[metricKey] = (metrics[metricKey] ?? 0) + increment;

    await prefs.setString(_userMetricsKey, jsonEncode(metrics));
  }
}
