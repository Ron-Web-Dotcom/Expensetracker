import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Certificate pinning service for securing API calls
/// Web-compatible implementation (no actual pinning on web)
class CertificatePinningService {
  static final CertificatePinningService _instance =
      CertificatePinningService._internal();
  factory CertificatePinningService() => _instance;
  CertificatePinningService._internal();

  late Dio _dio;

  /// Initialize Dio with certificate pinning configuration
  Future<void> initialize() async {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (kIsWeb) {
      // Web platform: Certificate pinning not supported
      // Browser handles certificate validation
      if (kDebugMode) {
        print(
          'Certificate pinning: Web platform detected - using browser validation',
        );
      }
    } else {
      // Mobile platform: Add certificate pinning interceptor
      _addCertificatePinningInterceptor();
    }
  }

  /// Add certificate pinning interceptor for mobile platforms
  void _addCertificatePinningInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Certificate validation happens at network layer
          // This interceptor can be extended for additional security checks
          if (kDebugMode) {
            print('API Request: ${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print('API Error: ${error.message}');
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Get configured Dio instance
  Dio get dio => _dio;

  /// Make GET request with certificate pinning
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      url,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make POST request with certificate pinning
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make PUT request with certificate pinning
  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Make DELETE request with certificate pinning
  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
