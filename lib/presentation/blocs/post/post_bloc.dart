import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'package:inkstreak/data/models/user_models.dart' as api_models;
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/core/utils/storage_service.dart';
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

  PostBloc()
      : _apiService = ApiService(DioClient.createDio()),
        super(const PostInitial()) {
    on<PostLoadRequested>(_onPostLoadRequested);
    on<PostRefreshRequested>(_onPostRefreshRequested);
    on<PostLoadByFilter>(_onPostLoadByFilter);
    on<PostYeahToggled>(_onPostYeahToggled);
    on<PostCommentCountUpdated>(_onPostCommentCountUpdated);
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final storage = await StorageService.getInstance();

      // Try to get user ID from JWT token first (most reliable)
      final token = await storage.read(key: AppConstants.tokenKey);
      if (token != null) {
        try {
          final decodedToken = JwtDecoder.decode(token);
          debugPrint('Decoded JWT token: $decodedToken');

          final userId = decodedToken['id'];
          debugPrint('User ID from JWT: $userId (type: ${userId.runtimeType})');

          if (userId is int) {
            _currentUserId = userId;
            debugPrint('SUCCESS: Loaded current user ID from JWT: $_currentUserId');
            return;
          } else if (userId is String) {
            _currentUserId = int.tryParse(userId);
            if (_currentUserId != null) {
              debugPrint('SUCCESS: Loaded current user ID from JWT (parsed): $_currentUserId');
              return;
            }
          }
        } catch (e) {
          debugPrint('Failed to decode JWT token: $e');
        }
      }

      // Fallback: try to get from stored user data
      final userJson = await storage.read(key: AppConstants.userKey);
      debugPrint('Raw user JSON from storage: $userJson');

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        debugPrint('Decoded user map: $userMap');

        final userId = userMap['id'];
        debugPrint('User ID from map: $userId (type: ${userId.runtimeType})');

        if (userId is int) {
          _currentUserId = userId;
          debugPrint('Set _currentUserId from int: $_currentUserId');
        } else if (userId is String) {
          _currentUserId = int.tryParse(userId);
          debugPrint('Set _currentUserId from String parse: $_currentUserId');
        } else {
          debugPrint('WARNING: userId is neither int nor String, type: ${userId.runtimeType}');
        }

        if (_currentUserId == null) {
          debugPrint('ERROR: Failed to set _currentUserId from userId: $userId');
        } else {
          debugPrint('SUCCESS: Loaded current user ID: $_currentUserId');
        }
      } else {
        debugPrint('No user data found in storage');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading current user ID: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _onPostLoadRequested(
    PostLoadRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostLoading());

    // Ensure user ID is loaded before processing posts
    if (_currentUserId == null) {
      await _loadCurrentUserId();
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
          .map((apiPost) => _convertApiPostToUiPost(apiPost))
          .toList();

      emit(PostLoaded(posts: posts));
    } on DioException catch (e) {
      // If API fails, fallback to mock data for now
      debugPrint('API Error loading posts: ${e.message}');
      final posts = Post.getMockPosts();
      emit(PostLoaded(posts: posts));
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
          .map((apiPost) => _convertApiPostToUiPost(apiPost))
          .toList();

      emit(PostLoaded(posts: posts));
    } on DioException catch (e) {
      debugPrint('API Error refreshing posts: ${e.message}');
      // Keep current state if refresh fails
      if (state is PostLoaded) {
        emit(state);
      } else {
        final posts = Post.getMockPosts();
        emit(PostLoaded(posts: posts));
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

    // Ensure user ID is loaded before processing posts
    if (_currentUserId == null) {
      await _loadCurrentUserId();
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
          .map((apiPost) => _convertApiPostToUiPost(apiPost))
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
      // Fallback to mock data
      final posts = Post.getMockPosts();
      emit(PostLoaded(posts: posts));
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
              return _convertApiPostToUiPost(updatedPost);
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

  Post _convertApiPostToUiPost(api_models.Post apiPost) {
    // API now returns: author{id, username, profilePicture}, themeName, yeahs[], commentCount
    // Check if current user has yeahed this post
    final isYeahed = _currentUserId != null && apiPost.yeahs.contains(_currentUserId);

    final postId = apiPost.id.toString();

    // Use cached comment count if available (user opened comments), otherwise use API count
    final commentCount = _commentCountCache[postId] ?? apiPost.commentCount;

    debugPrint('Converting post ${apiPost.id}: currentUserId=$_currentUserId, yeahs=${apiPost.yeahs}, isYeahed=$isYeahed, commentCount=$commentCount (cached: ${_commentCountCache[postId]}, api: ${apiPost.commentCount})');

    return Post(
      id: postId,
      userId: apiPost.author.id.toString(),
      username: apiPost.author.username,
      avatarUrl: apiPost.author.profilePicture,
      imageUrl: apiPost.picture,
      caption: apiPost.caption,
      theme: apiPost.themeName,
      yeahCount: apiPost.yeahCount,
      commentCount: commentCount,
      createdAt: apiPost.createdAt,
      streakDay: apiPost.artistStreak,
      isYeahed: isYeahed,
    );
  }
}
