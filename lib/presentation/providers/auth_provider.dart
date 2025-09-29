import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:inkstreak/data/models/user_models.dart';
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/constants/constants.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/core/utils/storage_service.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  AuthState _authState = AuthState.unknown;

  late final ApiService _apiService;

  AuthProvider() {
    _apiService = ApiService(DioClient.createDio());
    _checkAuthState();
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthState get authState => _authState;
  bool get isAuthenticated => _authState == AuthState.authenticated;

  // Check if user is already authenticated
  Future<void> _checkAuthState() async {
    try {
      final storage = await StorageService.getInstance();
      final token = await storage.read(key: AppConstants.tokenKey);
      final userJson = await storage.read(key: AppConstants.userKey);

      if (token != null && userJson != null) {
        _currentUser = User.fromJson(json.decode(userJson));
        _authState = AuthState.authenticated;
      } else {
        _authState = AuthState.unauthenticated;
      }
    } catch (e) {
      _authState = AuthState.unauthenticated;
      print('Error checking auth state: $e');
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final loginRequest = LoginRequest(
        username: username.trim(),
        hashedPassword: password,
      );

      final response = await _apiService.login(loginRequest);

      // Save user data and token from response
      await _saveAuthData(response, response.user);

      _currentUser = response.user;
      _authState = AuthState.authenticated;
      _setLoading(false);

      return true;
    } on DioException catch (e) {
      _handleDioError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      // Clear stored data
      final storage = await StorageService.getInstance();
      await storage.delete(key: AppConstants.tokenKey);
      await storage.delete(key: AppConstants.userKey);

      _currentUser = null;
      _authState = AuthState.unauthenticated;
      _clearError();
    } catch (e) {
      print('Error during logout: $e');
    }

    _setLoading(false);
  }

  Future<void> _saveAuthData(AuthResponse response, User user) async {
    final storage = await StorageService.getInstance();
    await storage.write(key: AppConstants.tokenKey, value: response.token);
    await storage.write(key: AppConstants.userKey, value: json.encode(user.toJson()));
  }

  void _handleDioError(DioException error) {
    if (error.response != null) {
      switch (error.response!.statusCode) {
        case 401:
          _setError('Invalid username or password');
          break;
        case 404:
          _setError('User not found');
          break;
        case 500:
          _setError('Server error. Please try again later.');
          break;
        default:
          _setError('Login failed. Please try again.');
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
               error.type == DioExceptionType.receiveTimeout) {
      _setError('Connection timeout. Please check your internet connection.');
    } else {
      _setError('Network error. Please check your internet connection.');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}