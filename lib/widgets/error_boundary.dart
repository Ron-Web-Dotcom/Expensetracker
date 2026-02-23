import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/crashlytics_service.dart';
import '../services/logging_service.dart';

/// Error boundary widget that catches and handles errors gracefully
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String screenName;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    required this.screenName,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  final LoggingService _logger = LoggingService();
  final CrashlyticsService _crashlytics = CrashlyticsService();
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Set up error handling for this boundary
    FlutterError.onError = (details) {
      _handleError(details.exception, details.stack);
    };
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });

    // Log error
    _logger.error(
      'Error in ${widget.screenName}',
      error: error,
      stackTrace: stackTrace,
      data: {'screen': widget.screenName},
    );

    // Report to Crashlytics
    _crashlytics.recordError(error, stackTrace ?? StackTrace.current);
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!);
      }
      return _buildDefaultErrorWidget(context);
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                kDebugMode
                    ? _error.toString()
                    : 'We\'re sorry for the inconvenience. Please try again.',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mixin to add error handling to StatefulWidgets
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  final LoggingService _logger = LoggingService();
  final CrashlyticsService _crashlytics = CrashlyticsService();

  /// Handle error with logging and user feedback
  void handleError(
    Object error,
    StackTrace stackTrace, {
    String? context,
    bool showSnackBar = true,
  }) {
    // Log error
    _logger.error(
      context ?? 'Error in ${T.toString()}',
      error: error,
      stackTrace: stackTrace,
    );

    // Report to Crashlytics
    _crashlytics.recordError(error, stackTrace);

    // Show user feedback
    if (showSnackBar && mounted) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(
            kDebugMode
                ? error.toString()
                : 'An error occurred. Please try again.',
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(this.context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  /// Safe async operation with error handling
  Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    String? context,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleError(error, stackTrace, context: context);
      return null;
    }
  }
}
