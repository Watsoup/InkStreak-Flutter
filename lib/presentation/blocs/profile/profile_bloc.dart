import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:inkstreak/data/models/user_models.dart';
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/core/utils/storage_service.dart';
import 'package:inkstreak/core/constants/constants.dart';
import 'package:inkstreak/presentation/blocs/auth/auth_bloc.dart';
import 'package:inkstreak/presentation/blocs/auth/auth_event.dart';
import 'package:inkstreak/presentation/blocs/auth/auth_state.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService _apiService;
  final AuthBloc _authBloc;

  ProfileBloc({required AuthBloc authBloc})
      : _apiService = ApiService(DioClient.createDio()),
        _authBloc = authBloc,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfilePictureUpdateRequested>(_onProfilePictureUpdateRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfilePictureRemoveRequested>(_onProfilePictureRemoveRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      // Get current user from storage first
      final storage = await StorageService.getInstance();
      final userJson = await storage.read(key: AppConstants.userKey);

      if (userJson == null) {
        emit(const ProfileError(message: 'No user found'));
        return;
      }

      final localUser = User.fromJson(json.decode(userJson));

      // Fetch fresh data from API
      try {
        final apiUser = await _apiService.getUser(localUser.username);

        // Save updated user to storage
        await _saveUser(apiUser);

        // Update AuthBloc with fresh data
        _authBloc.add(AuthUserUpdated(user: apiUser));

        emit(ProfileLoaded(user: apiUser));
      } on DioException catch (e) {
        debugPrint('API Error loading profile: ${e.message}');
        // If API fails, use local data
        emit(ProfileLoaded(user: localUser));
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      emit(ProfileError(message: 'Failed to load profile: $e'));
    }
  }

  Future<void> _onProfilePictureUpdateRequested(
    ProfilePictureUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _getCurrentUser();
    if (currentUser == null) {
      emit(const ProfileError(message: 'No user found'));
      return;
    }

    emit(ProfileUpdating(user: currentUser));

    try {
      // Upload profile picture
      final response = await _apiService.updateProfilePicture(event.picture);

      if (response.success) {
        // Save updated user
        await _saveUser(response.user);

        // Update AuthBloc
        _authBloc.add(AuthUserUpdated(user: response.user));

        emit(ProfileLoaded(user: response.user));
      } else {
        emit(ProfileError(
          message: response.message,
          user: currentUser,
        ));
      }
    } on DioException catch (e) {
      debugPrint('Profile picture upload error: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      final errorMessage = _handleDioError(e);
      emit(ProfileError(message: errorMessage, user: currentUser));
    } catch (e) {
      debugPrint('Unexpected profile picture upload error: $e');
      emit(ProfileError(
        message: 'Failed to upload profile picture: $e',
        user: currentUser,
      ));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _getCurrentUser();
    if (currentUser == null) {
      emit(const ProfileError(message: 'No user found'));
      return;
    }

    emit(ProfileUpdating(user: currentUser));

    try {
      // Only include fields that are being updated
      final request = UpdateProfileRequest(
        bio: event.bio,
        // Don't include profilePicture field to avoid overwriting it
      );
      final response = await _apiService.updateProfile(request);

      if (response.success) {
        // Save updated user
        await _saveUser(response.user);

        // Update AuthBloc
        _authBloc.add(AuthUserUpdated(user: response.user));

        emit(ProfileLoaded(user: response.user));
      } else {
        emit(ProfileError(
          message: response.message,
          user: currentUser,
        ));
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      emit(ProfileError(message: errorMessage, user: currentUser));
    } catch (e) {
      emit(ProfileError(
        message: 'Failed to update profile: $e',
        user: currentUser,
      ));
    }
  }

  Future<void> _onProfilePictureRemoveRequested(
    ProfilePictureRemoveRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _getCurrentUser();
    if (currentUser == null) {
      emit(const ProfileError(message: 'No user found'));
      return;
    }

    emit(ProfileUpdating(user: currentUser));

    try {
      // Update profile with null profilePicture
      final request = UpdateProfileRequest(profilePicture: '');
      final response = await _apiService.updateProfile(request);

      if (response.success) {
        // Save updated user
        await _saveUser(response.user);

        // Update AuthBloc
        _authBloc.add(AuthUserUpdated(user: response.user));

        emit(ProfileLoaded(user: response.user));
      } else {
        emit(ProfileError(
          message: response.message,
          user: currentUser,
        ));
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      emit(ProfileError(message: errorMessage, user: currentUser));
    } catch (e) {
      emit(ProfileError(
        message: 'Failed to remove profile picture: $e',
        user: currentUser,
      ));
    }
  }

  User? _getCurrentUser() {
    final authState = _authBloc.state;
    if (authState is AuthAuthenticated) {
      return authState.user;
    }
    return null;
  }

  Future<void> _saveUser(User user) async {
    final storage = await StorageService.getInstance();
    await storage.write(
      key: AppConstants.userKey,
      value: json.encode(user.toJson()),
    );
  }

  String _handleDioError(DioException error) {
    if (error.response != null) {
      // Check for specific error messages from server
      final responseData = error.response!.data;
      if (responseData is Map && responseData['error'] != null) {
        final errorMsg = responseData['error'].toString();
        if (errorMsg.contains('Access Denied')) {
          return 'Profile picture upload is currently unavailable. Please try updating your bio only.';
        }
      }

      switch (error.response!.statusCode) {
        case 400:
          return 'Invalid file or request';
        case 401:
          return 'Unauthorized. Please log in again.';
        case 413:
          return 'File is too large. Please select a smaller image.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Update failed. Please try again.';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else {
      return 'Network error. Please check your internet connection.';
    }
  }
}
