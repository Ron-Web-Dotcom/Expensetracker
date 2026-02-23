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
      'platform': kIsWeb ? 'web' : 'mobile',
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

  /// Track screen transition
  Future<void> trackScreenTransition(String fromScreen, String toScreen) async {
    await _logEvent('screen_transition', {
      'from_screen': fromScreen,
      'to_screen': toScreen,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track button click
  Future<void> trackButtonClick(String buttonName, String screenName) async {
    await _logEvent('button_click', {
      'button_name': buttonName,
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track form submission
  Future<void> trackFormSubmission(
    String formName,
    bool success, {
    String? errorMessage,
  }) async {
    await _logEvent('form_submission', {
      'form_name': formName,
      'success': success,
      'error_message': errorMessage,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track search query
  Future<void> trackSearch(String query, int resultsCount) async {
    await _logEvent('search', {
      'query_length': query.length,
      'results_count': resultsCount,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track error occurrence
  Future<void> trackError(
    String errorType,
    String errorMessage, {
    String? screenName,
  }) async {
    await _logEvent('error_occurred', {
      'error_type': errorType,
      'error_message': errorMessage,
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track user retention
  Future<void> trackUserRetention() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLaunch = prefs.getString('first_launch_date');

    if (firstLaunch == null) {
      await prefs.setString(
        'first_launch_date',
        DateTime.now().toIso8601String(),
      );
    } else {
      final firstLaunchDate = DateTime.parse(firstLaunch);
      final daysSinceFirstLaunch = DateTime.now()
          .difference(firstLaunchDate)
          .inDays;

      await _logEvent('user_retention', {
        'days_since_first_launch': daysSinceFirstLaunch,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Get user engagement metrics
  Future<Map<String, dynamic>> getEngagementMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final metricsJson = prefs.getString(_userMetricsKey);
    final metrics = metricsJson != null
        ? jsonDecode(metricsJson) as Map<String, dynamic>
        : <String, dynamic>{};

    final eventsJson = prefs.getString(_eventsKey);
    final events = eventsJson != null
        ? (jsonDecode(eventsJson) as List)
              .map((e) => e as Map<String, dynamic>)
              .toList()
        : <Map<String, dynamic>>[];

    final sessionEvents = events
        .where((e) => e['event_name'] == 'session_end')
        .toList();
    final avgSessionDuration = sessionEvents.isEmpty
        ? 0
        : sessionEvents
                  .map((e) => e['duration_seconds'] as int)
                  .reduce((a, b) => a + b) /
              sessionEvents.length;

    return {
      'total_sessions': metrics['total_sessions'] ?? 0,
      'avg_session_duration_seconds': avgSessionDuration,
      'total_expenses_added': metrics['total_expenses_added'] ?? 0,
      'total_events': events.length,
    };
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
