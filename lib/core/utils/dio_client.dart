import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:inkstreak/core/constants/constants.dart';
import 'package:inkstreak/core/utils/storage_service.dart';

class DioClient {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(seconds: AppConstants.timeoutDuration),
        receiveTimeout: Duration(seconds: AppConstants.timeoutDuration),
        sendTimeout: Duration(seconds: AppConstants.timeoutDuration),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // Add certificate for HTTPS (if needed)
    // Note: For production, load actual certificate bytes
    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
    //   final SecurityContext context = SecurityContext();
    //   context.setTrustedCertificatesBytes(certificateBytes);
    //   return HttpClient(context: context);
    // };

    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    ]);

    return dio;
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip token for login and register endpoints
    if (options.path.contains('/auth/login') || options.path.contains('/auth/register')) {
      handler.next(options);
      return;
    }

    try {
      final storage = await StorageService.getInstance();
      final token = await storage.read(key: AppConstants.tokenKey);

      if (token != null) {
        // Validate token before using it
        if (_isTokenExpired(token)) {
          debugPrint('AuthInterceptor: Token has expired. Clearing stored credentials.');
          await storage.delete(key: AppConstants.tokenKey);
          await storage.delete(key: AppConstants.userKey);

          // Reject the request with a clear error
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 401,
                statusMessage: 'Token expired',
                data: {'error': 'Your session has expired. Please login again.'},
              ),
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }

        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('AuthInterceptor: Added Authorization header to ${options.path}');
      } else {
        debugPrint('AuthInterceptor: No token found for ${options.path}');
      }
    } catch (e) {
      debugPrint('AuthInterceptor: Error reading token: $e');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      debugPrint('AuthInterceptor: 401 error received. Response: ${err.response?.data}');
      // Token expired or invalid - clear stored token
      try {
        final storage = await StorageService.getInstance();
        await storage.delete(key: AppConstants.tokenKey);
        await storage.delete(key: AppConstants.userKey);
        debugPrint('AuthInterceptor: Cleared stored credentials due to 401 error');
      } catch (e) {
        debugPrint('AuthInterceptor: Error clearing tokens: $e');
      }
    }
    handler.next(err);
  }

  /// Validates if a JWT token has expired
  bool _isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      debugPrint('AuthInterceptor: Error decoding token: $e');
      // If we can't decode the token, consider it invalid/expired
      return true;
    }
  }
}