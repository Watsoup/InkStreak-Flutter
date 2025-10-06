import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:inkstreak/data/models/user_models.dart';
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/constants/constants.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/core/utils/storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService;

  AuthBloc() : _apiService = ApiService(DioClient.createDio()), super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthErrorCleared>(_onAuthErrorCleared);

    // Check auth state on initialization
    add(const AuthCheckRequested());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final storage = await StorageService.getInstance();
      final token = await storage.read(key: AppConstants.tokenKey);
      final userJson = await storage.read(key: AppConstants.userKey);

      if (token != null && userJson != null) {
        final user = User.fromJson(json.decode(userJson));
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      print('Error checking auth state: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final loginRequest = LoginRequest(
        username: event.username.trim(),
        hashedPassword: event.hashedPassword,
      );

      final response = await _apiService.login(loginRequest);

      // Create a user object from the login request data
      final user = User(
        id: event.username, // Using username as ID temporarily
        username: event.username,
        createdAt: DateTime.now(),
      );

      // Save user data and token from response
      await _saveAuthData(response, user);

      emit(AuthAuthenticated(user: user));
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      emit(AuthUnauthenticated(errorMessage: errorMessage));
    } catch (e) {
      emit(const AuthUnauthenticated(
        errorMessage: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Clear stored data
      final storage = await StorageService.getInstance();
      await storage.delete(key: AppConstants.tokenKey);
      await storage.delete(key: AppConstants.userKey);

      emit(const AuthUnauthenticated());
    } catch (e) {
      print('Error during logout: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthErrorCleared(
    AuthErrorCleared event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthUnauthenticated) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _saveAuthData(AuthResponse response, User user) async {
    final storage = await StorageService.getInstance();
    await storage.write(key: AppConstants.tokenKey, value: response.token);
    await storage.write(key: AppConstants.userKey, value: json.encode(user.toJson()));
  }

  String _handleDioError(DioException error) {
    if (error.response != null) {
      switch (error.response!.statusCode) {
        case 401:
          return 'Invalid username or password';
        case 404:
          return 'User not found';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Login failed. Please try again.';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
               error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else {
      return 'Network error. Please check your internet connection.';
    }
  }
}
