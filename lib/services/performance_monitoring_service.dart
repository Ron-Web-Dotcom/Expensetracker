import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Performance monitoring service for tracking app performance metrics
/// Monitors FPS, memory usage, frame rendering times, and app launch performance
class PerformanceMonitoringService {
  static final PerformanceMonitoringService _instance =
      PerformanceMonitoringService._internal();
  factory PerformanceMonitoringService() => _instance;
  PerformanceMonitoringService._internal();

  static const String _metricsKey = 'performance_metrics';
  static const String _fpsKey = 'fps_history';
  static const String _memoryKey = 'memory_history';

  DateTime? _appStartTime;
  DateTime? _firstFrameTime;
  final List<double> _fpsHistory = [];
  final List<int> _frameTimesMs = [];
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  /// Initialize performance monitoring
  void initialize() {
    _appStartTime = DateTime.now();

    // Track first frame render
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _firstFrameTime = DateTime.now();
      _recordAppLaunchTime();
    });

    // Start FPS monitoring in debug mode
    if (kDebugMode) {
      startMonitoring();
    }
  }

  /// Start continuous performance monitoring
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _measureFPS();
    });
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// Measure current FPS
  void _measureFPS() {
    if (_frameTimesMs.isEmpty) return;

    // Calculate average frame time
    final avgFrameTime =
        _frameTimesMs.reduce((a, b) => a + b) / _frameTimesMs.length;

    // Convert to FPS (1000ms / avgFrameTime)
    final fps = avgFrameTime > 0 ? 1000 / avgFrameTime : 60.0;

    _fpsHistory.add(fps.clamp(0, 60));

    // Keep only last 60 seconds of data
    if (_fpsHistory.length > 60) {
      _fpsHistory.removeAt(0);
    }

    _frameTimesMs.clear();

    // Log performance warning if FPS drops below 30
    if (fps < 30 && kDebugMode) {
      debugPrint(
        '⚠️ Performance Warning: FPS dropped to ${fps.toStringAsFixed(1)}',
      );
    }
  }

  /// Record frame rendering time
  void recordFrameTime(Duration frameDuration) {
    _frameTimesMs.add(frameDuration.inMilliseconds);
  }

  /// Get current average FPS
  double getCurrentFPS() {
    if (_fpsHistory.isEmpty) return 60.0;
    return _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
  }

  /// Get FPS history for visualization
  List<double> getFPSHistory() {
    return List.unmodifiable(_fpsHistory);
  }

  /// Record app launch time
  Future<void> _recordAppLaunchTime() async {
    if (_appStartTime == null || _firstFrameTime == null) return;

    final launchTime = _firstFrameTime!
        .difference(_appStartTime!)
        .inMilliseconds;

    final prefs = await SharedPreferences.getInstance();
    final metrics = await _getMetrics();

    metrics['last_launch_time_ms'] = launchTime;
    metrics['launch_count'] = (metrics['launch_count'] as int? ?? 0) + 1;

    // Calculate average launch time
    final launchHistory = metrics['launch_history'] as List? ?? [];
    launchHistory.add(launchTime);
    if (launchHistory.length > 10) {
      launchHistory.removeAt(0);
    }
    metrics['launch_history'] = launchHistory;

    final avgLaunchTime =
        launchHistory.reduce((a, b) => a + b) / launchHistory.length;
    metrics['avg_launch_time_ms'] = avgLaunchTime;

    await prefs.setString(_metricsKey, jsonEncode(metrics));

    if (kDebugMode) {
      debugPrint(
        '📊 App Launch Time: ${launchTime}ms (Avg: ${avgLaunchTime.toStringAsFixed(0)}ms)',
      );
    }
  }

  /// Get performance metrics
  Future<Map<String, dynamic>> _getMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final metricsJson = prefs.getString(_metricsKey);

    if (metricsJson == null) {
      return {
        'launch_count': 0,
        'launch_history': [],
        'last_launch_time_ms': 0,
        'avg_launch_time_ms': 0,
      };
    }

    return Map<String, dynamic>.from(jsonDecode(metricsJson));
  }

  /// Get all performance metrics
  Future<Map<String, dynamic>> getAllMetrics() async {
    final metrics = await _getMetrics();

    return {
      ...metrics,
      'current_fps': getCurrentFPS(),
      'fps_history': _fpsHistory,
      'is_monitoring': _isMonitoring,
      'target_fps': 60,
      'performance_score': _calculatePerformanceScore(),
    };
  }

  /// Calculate overall performance score (0-100)
  int _calculatePerformanceScore() {
    final currentFPS = getCurrentFPS();

    // FPS score (60 FPS = 100 points)
    final fpsScore = (currentFPS / 60 * 100).clamp(0, 100);

    return fpsScore.round();
  }

  /// Track screen rendering performance
  Future<void> trackScreenRender(String screenName, Duration renderTime) async {
    final prefs = await SharedPreferences.getInstance();
    final metrics = await _getMetrics();

    final screenMetrics =
        metrics['screen_metrics'] as Map<String, dynamic>? ?? {};
    final screenData =
        screenMetrics[screenName] as Map<String, dynamic>? ??
        {'render_times': [], 'render_count': 0};

    final renderTimes = List<int>.from(
      screenData['render_times'] as List? ?? [],
    );
    renderTimes.add(renderTime.inMilliseconds);

    // Keep only last 20 renders
    if (renderTimes.length > 20) {
      renderTimes.removeAt(0);
    }

    screenData['render_times'] = renderTimes;
    screenData['render_count'] = (screenData['render_count'] as int? ?? 0) + 1;
    screenData['avg_render_time'] =
        renderTimes.reduce((a, b) => a + b) / renderTimes.length;
    screenData['last_render_time'] = renderTime.inMilliseconds;

    screenMetrics[screenName] = screenData;
    metrics['screen_metrics'] = screenMetrics;

    await prefs.setString(_metricsKey, jsonEncode(metrics));

    // Log slow renders
    if (renderTime.inMilliseconds > 100 && kDebugMode) {
      debugPrint(
        '⚠️ Slow Render: $screenName took ${renderTime.inMilliseconds}ms',
      );
    }
  }

  /// Get screen-specific metrics
  Future<Map<String, dynamic>?> getScreenMetrics(String screenName) async {
    final metrics = await _getMetrics();
    final screenMetrics =
        metrics['screen_metrics'] as Map<String, dynamic>? ?? {};
    return screenMetrics[screenName] as Map<String, dynamic>?;
  }

  /// Clear all performance metrics
  Future<void> clearMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_metricsKey);
    await prefs.remove(_fpsKey);
    await prefs.remove(_memoryKey);
    _fpsHistory.clear();
    _frameTimesMs.clear();
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _fpsHistory.clear();
    _frameTimesMs.clear();
  }
}
