import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'follow_event.dart';
import 'follow_state.dart';

class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final ApiService _apiService;

  // Cache follow status for each user to prevent flicker
  final Map<String, bool> _followStatusCache = {};

  FollowBloc()
      : _apiService = ApiService(DioClient.createDio()),
        super(const FollowInitial()) {
    on<FollowToggleRequested>(_onFollowToggleRequested);
    on<FollowStatusRequested>(_onFollowStatusRequested);
    on<FollowersListRequested>(_onFollowersListRequested);
    on<FollowingListRequested>(_onFollowingListRequested);
  }

  Future<void> _onFollowToggleRequested(
    FollowToggleRequested event,
    Emitter<FollowState> emit,
  ) async {
    final currentIsFollowing = _followStatusCache[event.username] ?? false;
    final targetIsFollowing = !currentIsFollowing;

    debugPrint('Follow toggle - User: ${event.username}, Current: $currentIsFollowing, Target: $targetIsFollowing');

    // Get current counts if in FollowStatusLoaded state
    int currentFollowerCount = 0;
    int currentFollowingCount = 0;

    if (state is FollowStatusLoaded) {
      final currentState = state as FollowStatusLoaded;
      if (currentState.username == event.username) {
        currentFollowerCount = currentState.followerCount;
        currentFollowingCount = currentState.followingCount;
      }
    }

    // Optimistic update
    final targetFollowerCount = targetIsFollowing
        ? currentFollowerCount + 1
        : (currentFollowerCount > 0 ? currentFollowerCount - 1 : 0);

    emit(FollowToggling(
      username: event.username,
      targetIsFollowing: targetIsFollowing,
      followerCount: targetFollowerCount,
      followingCount: currentFollowingCount,
    ));

    // Update cache optimistically
    _followStatusCache[event.username] = targetIsFollowing;

    try {
      // Call API to toggle follow
      final response = await _apiService.followUser(event.username);

      if (response.success) {
        // Verify API response matches our optimistic update
        final apiIsFollowing = response.isFollowing;

        debugPrint('Follow toggle API response - Expected: $targetIsFollowing, Got: $apiIsFollowing');

        // Update cache with API response
        _followStatusCache[event.username] = apiIsFollowing;

        // Use optimistic counts since API doesn't return follower arrays
        emit(FollowStatusLoaded(
          username: event.username,
          isFollowing: apiIsFollowing,
          followerCount: targetFollowerCount,
          followingCount: currentFollowingCount,
        ));
      } else {
        // API indicated failure, revert
        _followStatusCache[event.username] = currentIsFollowing;
        emit(FollowError(
          message: 'Failed to update follow status',
          username: event.username,
        ));
      }
    } on DioException catch (e) {
      debugPrint('API Error toggling follow: ${e.message}');
      // Revert optimistic update on API failure
      _followStatusCache[event.username] = currentIsFollowing;

      final errorMessage = _handleDioError(e);
      emit(FollowError(
        message: errorMessage,
        username: event.username,
      ));
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      // Revert optimistic update on error
      _followStatusCache[event.username] = currentIsFollowing;

      emit(FollowError(
        message: 'Failed to update follow status: $e',
        username: event.username,
      ));
    }
  }

  Future<void> _onFollowStatusRequested(
    FollowStatusRequested event,
    Emitter<FollowState> emit,
  ) async {
    emit(const FollowLoading());

    try {
      // Check if user follows the target user
      final response = await _apiService.isFollowing(event.username);
      final isFollowing = response.isFollowing;

      // Update cache
      _followStatusCache[event.username] = isFollowing;

      // API doesn't return follower arrays, so emit with default counts
      // Counts will be managed optimistically during follow/unfollow
      emit(FollowStatusLoaded(
        username: event.username,
        isFollowing: isFollowing,
        followerCount: 0,
        followingCount: 0,
      ));
    } on DioException catch (e) {
      debugPrint('API Error checking follow status: ${e.message}');
      final errorMessage = _handleDioError(e);
      emit(FollowError(
        message: errorMessage,
        username: event.username,
      ));
    } catch (e) {
      debugPrint('Error checking follow status: $e');
      emit(FollowError(
        message: 'Failed to check follow status: $e',
        username: event.username,
      ));
    }
  }

  Future<void> _onFollowersListRequested(
    FollowersListRequested event,
    Emitter<FollowState> emit,
  ) async {
    emit(const FollowLoading());

    try {
      final user = await _apiService.getUser(event.username);
      final followers = user.followers ?? [];

      emit(FollowListLoaded(
        username: event.username,
        usernames: followers,
        listType: FollowListType.followers,
      ));
    } on DioException catch (e) {
      debugPrint('API Error loading followers: ${e.message}');
      final errorMessage = _handleDioError(e);
      emit(FollowError(
        message: errorMessage,
        username: event.username,
      ));
    } catch (e) {
      debugPrint('Error loading followers: $e');
      emit(FollowError(
        message: 'Failed to load followers: $e',
        username: event.username,
      ));
    }
  }

  Future<void> _onFollowingListRequested(
    FollowingListRequested event,
    Emitter<FollowState> emit,
  ) async {
    emit(const FollowLoading());

    try {
      final user = await _apiService.getUser(event.username);
      final following = user.following ?? [];

      emit(FollowListLoaded(
        username: event.username,
        usernames: following,
        listType: FollowListType.following,
      ));
    } on DioException catch (e) {
      debugPrint('API Error loading following: ${e.message}');
      final errorMessage = _handleDioError(e);
      emit(FollowError(
        message: errorMessage,
        username: event.username,
      ));
    } catch (e) {
      debugPrint('Error loading following: $e');
      emit(FollowError(
        message: 'Failed to load following: $e',
        username: event.username,
      ));
    }
  }

  String _handleDioError(DioException error) {
    if (error.response != null) {
      switch (error.response!.statusCode) {
        case 400:
          return 'Invalid request';
        case 401:
          return 'Unauthorized. Please log in again.';
        case 404:
          return 'User not found';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Request failed. Please try again.';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else {
      return 'Network error. Please check your internet connection.';
    }
  }
}
