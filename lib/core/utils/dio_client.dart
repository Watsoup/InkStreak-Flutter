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
    if (options.path.contains('/auth/login') || options.path.contains('/auth/register')) {
      handler.next(options);
      return;
    }

    try {
      final storage = await StorageService.getInstance();
      final token = await storage.read(key: AppConstants.tokenKey);

      if (token != null) {
        if (_isTokenExpired(token)) {
          await storage.delete(key: AppConstants.tokenKey);
          await storage.delete(key: AppConstants.userKey);

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
      }
    } catch (e) {
      debugPrint('AuthInterceptor: Error reading token: $e');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid - clear stored token
      try {
        final storage = await StorageService.getInstance();
        await storage.delete(key: AppConstants.tokenKey);
        await storage.delete(key: AppConstants.userKey);
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