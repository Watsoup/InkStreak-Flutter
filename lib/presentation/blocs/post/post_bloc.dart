import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'package:inkstreak/data/models/user_models.dart' as api_models;
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/core/utils/user_id_provider.dart';
import 'package:inkstreak/core/utils/post_mapper.dart';
import 'package:inkstreak/core/constants/constants.dart';
import 'dart:math';
import 'dart:convert';
import 'post_event.dart';
import 'post_state.dart';
import 'post_filters.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final ApiService _apiService;
  int? _currentUserId;

  // Cache comment counts to persist across reloads
  final Map<String, int> _commentCountCache = {};

  PostBloc({required ApiService apiService})
      : _apiService = apiService,
        super(const PostInitial()) {
    on<PostLoadRequested>(_onPostLoadRequested);
    on<PostRefreshRequested>(_onPostRefreshRequested);
    on<PostLoadByFilter>(_onPostLoadByFilter);
    on<PostYeahToggled>(_onPostYeahToggled);
    on<PostCommentCountUpdated>(_onPostCommentCountUpdated);
    _initUserId();
  }

  Future<void> _initUserId() async {
    _currentUserId = await UserIdProvider.getCurrentUserId();
  }

  Future<void> _onPostLoadRequested(
    PostLoadRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostLoading());

    if (_currentUserId == null) {
      _currentUserId = await UserIdProvider.getCurrentUserId();
    }

    try {
      // Fetch all posts (not just followed users)
      final apiPosts = await _apiService.getAllPosts();

      // Filter posts to show only those created today
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Convert API posts to UI posts and filter for today only
      final posts = apiPosts
          .where((apiPost) =>
              apiPost.createdAt.isAfter(todayStart) &&
              apiPost.createdAt.isBefore(todayEnd))
          .map((apiPost) => PostMapper.fromApiPost(
                apiPost,
                currentUserId: _currentUserId,
                commentCountCache: _commentCountCache,
              ))
          .toList();

      emit(PostLoaded(posts: posts));
    } on DioException catch (e) {
      debugPrint('API Error loading posts: ${e.message}');
    } catch (e) {
      emit(PostError(message: 'Failed to load posts: $e'));
    }
  }

  Future<void> _onPostRefreshRequested(
    PostRefreshRequested event,
    Emitter<PostState> emit,
  ) async {
    try {
      // Fetch all posts (not just followed users)
      final apiPosts = await _apiService.getAllPosts();

      // Filter posts to show only those created today
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Convert API posts to UI posts and filter for today only
      final posts = apiPosts
          .where((apiPost) =>
              apiPost.createdAt.isAfter(todayStart) &&
              apiPost.createdAt.isBefore(todayEnd))
          .map((apiPost) => PostMapper.fromApiPost(
                apiPost,
                currentUserId: _currentUserId,
                commentCountCache: _commentCountCache,
              ))
          .toList();

      emit(PostLoaded(posts: posts));
    } on DioException catch (e) {
      debugPrint('API Error refreshing posts: ${e.message}');
      // Keep current state if refresh fails
      if (state is PostLoaded) {
        emit(state);
      }
    } catch (e) {
      // Keep current state if refresh fails
      if (state is PostLoaded) {
        emit(state);
      } else {
        emit(PostError(message: 'Failed to refresh posts: $e'));
      }
    }
  }

  Future<void> _onPostLoadByFilter(
    PostLoadByFilter event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostLoading());

    if (_currentUserId == null) {
      _currentUserId = await UserIdProvider.getCurrentUserId();
    }

    try {
      // Fetch posts based on feed type
      List<api_models.Post> apiPosts;

      if (event.feedType == FeedType.everyone) {
        apiPosts = await _apiService.getAllPosts();
      } else {
        // Get feed of followed users (uses authentication token)
        apiPosts = await _apiService.getFeed();
      }

      // Apply time period filter
      final dateRange = event.timePeriod.getDateRange();
      var filteredPosts = apiPosts
          .where((apiPost) =>
              apiPost.createdAt.isAfter(dateRange.start) &&
              apiPost.createdAt.isBefore(dateRange.end))
          .map((apiPost) => PostMapper.fromApiPost(
                apiPost,
                currentUserId: _currentUserId,
                commentCountCache: _commentCountCache,
              ))
          .toList();

      // Apply sorting
      if (event.sortType == SortType.best) {
        filteredPosts.sort((a, b) => b.yeahCount.compareTo(a.yeahCount));
      } else if (event.sortType == SortType.random) {
        filteredPosts.shuffle(Random());
      }

      emit(PostLoaded(posts: filteredPosts));
    } on DioException catch (e) {
      debugPrint('API Error loading filtered posts: ${e.message}');
    } catch (e) {
      emit(PostError(message: 'Failed to load posts: $e'));
    }
  }

  Future<void> _onPostYeahToggled(
    PostYeahToggled event,
    Emitter<PostState> emit,
  ) async {
    if (state is! PostLoaded) return;

    final currentState = state as PostLoaded;

    // Get the current post to know the target state
    final targetPost = currentState.posts.firstWhere((p) => p.id == event.postId);
    final targetIsYeahed = !targetPost.isYeahed;
    final targetYeahCount = targetPost.isYeahed
        ? targetPost.yeahCount - 1
        : targetPost.yeahCount + 1;

    debugPrint('Yeah toggle started - Post: ${event.postId}, Current: ${targetPost.isYeahed}, Target: $targetIsYeahed, CurrentUserId: $_currentUserId');

    // Optimistically update UI
    final updatedPosts = currentState.posts.map((post) {
      if (post.id == event.postId) {
        return post.copyWith(
          isYeahed: targetIsYeahed,
          yeahCount: targetYeahCount,
        );
      }
      return post;
    }).toList();

    emit(PostLoaded(posts: updatedPosts));

    try {
      // Call API to toggle yeah
      final postId = int.tryParse(event.postId);
      if (postId != null) {
        final updatedPost = await _apiService.toggleYeah(postId);

        // Verify the API response matches our optimistic update
        final apiIsYeahed = _currentUserId != null && updatedPost.yeahs.contains(_currentUserId);

        debugPrint('Yeah toggle - Target: $targetIsYeahed, API: $apiIsYeahed, Count: ${updatedPost.yeahCount}');

        // Only update if API response differs from optimistic update
        // This prevents the flicker issue
        if (apiIsYeahed != targetIsYeahed || updatedPost.yeahCount != targetYeahCount) {
          debugPrint('API response differs from optimistic update, syncing...');
          final finalPosts = updatedPosts.map((post) {
            if (post.id == event.postId) {
              return PostMapper.fromApiPost(
                updatedPost,
                currentUserId: _currentUserId,
                commentCountCache: _commentCountCache,
              );
            }
            return post;
          }).toList();
          emit(PostLoaded(posts: finalPosts));
        } else {
          debugPrint('API response matches optimistic update, keeping current state');
        }
      }
    } on DioException catch (e) {
      debugPrint('API Error toggling yeah: ${e.message}');
      // Revert optimistic update on API failure - restore original state
      emit(PostLoaded(posts: currentState.posts));
    } catch (e) {
      debugPrint('Error toggling yeah: $e');
      // Revert optimistic update on error - restore original state
      emit(PostLoaded(posts: currentState.posts));
    }
  }

  Future<void> _onPostCommentCountUpdated(
    PostCommentCountUpdated event,
    Emitter<PostState> emit,
  ) async {
    if (state is! PostLoaded) return;

    final currentState = state as PostLoaded;

    // Cache the comment count so it persists across reloads
    _commentCountCache[event.postId] = event.commentCount;

    // Update the comment count for the specific post
    final updatedPosts = currentState.posts.map((post) {
      if (post.id == event.postId) {
        return post.copyWith(commentCount: event.commentCount);
      }
      return post;
    }).toList();

    emit(PostLoaded(posts: updatedPosts));
  }
}
