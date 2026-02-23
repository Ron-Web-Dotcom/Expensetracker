import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// PII-safe logging service for production environments
/// Filters out personally identifiable information from logs
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  // PII patterns to filter
  static final List<RegExp> _piiPatterns = [
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Email
    RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'), // Phone numbers
    RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), // SSN
    RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), // Credit card
    RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'), // IP address
  ];

  // Sensitive keys to redact
  static final List<String> _sensitiveKeys = [
    'password',
    'token',
    'apiKey',
    'api_key',
    'secret',
    'authorization',
    'auth',
    'creditCard',
    'credit_card',
    'ssn',
    'social_security',
  ];

  /// Log debug message (only in debug mode)
  void debug(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final sanitized = _sanitizeMessage(message);
      final sanitizedData = data != null ? _sanitizeData(data) : null;
      developer.log(
        sanitized,
        name: 'ExpenseTracker',
        level: 500, // Debug level
        error: sanitizedData,
      );
    }
  }

  /// Log info message
  void info(String message, {Map<String, dynamic>? data}) {
    final sanitized = _sanitizeMessage(message);
    final sanitizedData = data != null ? _sanitizeData(data) : null;
    developer.log(
      sanitized,
      name: 'ExpenseTracker',
      level: 800, // Info level
      error: sanitizedData,
    );
  }

  /// Log warning message
  void warning(String message, {Map<String, dynamic>? data}) {
    final sanitized = _sanitizeMessage(message);
    final sanitizedData = data != null ? _sanitizeData(data) : null;
    developer.log(
      sanitized,
      name: 'ExpenseTracker',
      level: 900, // Warning level
      error: sanitizedData,
    );
  }

  /// Log error message
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    final sanitized = _sanitizeMessage(message);
    final sanitizedData = data != null ? _sanitizeData(data) : null;
    developer.log(
      sanitized,
      name: 'ExpenseTracker',
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );

    if (sanitizedData != null && kDebugMode) {
      developer.log(
        'Error data: $sanitizedData',
        name: 'ExpenseTracker',
        level: 1000,
      );
    }
  }

  /// Sanitize message by removing PII
  String _sanitizeMessage(String message) {
    String sanitized = message;

    // Replace PII patterns
    for (final pattern in _piiPatterns) {
      sanitized = sanitized.replaceAll(pattern, '[REDACTED]');
    }

    return sanitized;
  }

  /// Sanitize data map by redacting sensitive keys
  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    data.forEach((key, value) {
      // Check if key is sensitive
      final isSensitive = _sensitiveKeys.any(
        (sensitiveKey) =>
            key.toLowerCase().contains(sensitiveKey.toLowerCase()),
      );

      if (isSensitive) {
        sanitized[key] = '[REDACTED]';
      } else if (value is Map<String, dynamic>) {
        // Recursively sanitize nested maps
        sanitized[key] = _sanitizeData(value);
      } else if (value is String) {
        // Sanitize string values
        sanitized[key] = _sanitizeMessage(value);
      } else {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  /// Log user action (analytics-style logging)
  void logUserAction(String action, {Map<String, dynamic>? properties}) {
    info('User action: $action', data: properties);
  }

  /// Log performance metric
  void logPerformance(
    String metric,
    Duration duration, {
    Map<String, dynamic>? data,
  }) {
    info('Performance: $metric took ${duration.inMilliseconds}ms', data: data);
  }

  /// Log API call
  void logApiCall(String endpoint, {int? statusCode, Duration? duration}) {
    info(
      'API: $endpoint',
      data: {
        'status_code': statusCode,
        'duration_ms': duration?.inMilliseconds,
      },
    );
  }

  /// Log navigation event
  void logNavigation(String from, String to) {
    debug('Navigation: $from -> $to');
  }
}
