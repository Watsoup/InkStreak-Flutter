import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'package:inkstreak/data/models/user_models.dart' as api_models;
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/core/utils/storage_service.dart';
import 'package:inkstreak/core/constants/constants.dart';
import 'dart:convert';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final ApiService _apiService;

  PostBloc()
      : _apiService = ApiService(DioClient.createDio()),
        super(const PostInitial()) {
    on<PostLoadRequested>(_onPostLoadRequested);
    on<PostRefreshRequested>(_onPostRefreshRequested);
    on<PostYeahToggled>(_onPostYeahToggled);
  }

  Future<void> _onPostLoadRequested(
    PostLoadRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(const PostLoading());

    try {
      // Get current user's username from storage
      final storage = await StorageService.getInstance();
      final userJson = await storage.read(key: AppConstants.userKey);

      if (userJson == null) {
        // No user logged in, show mock posts
        final posts = Post.getMockPosts();
        emit(PostLoaded(posts: posts));
        return;
      }

      final user = api_models.User.fromJson(json.decode(userJson));

      // Fetch posts from followed users
      final apiPosts = await _apiService.getFollowedPosts(user.username);

      // Convert API posts to UI posts
      final posts = apiPosts.map((apiPost) => _convertApiPostToUiPost(apiPost)).toList();

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
      // Get current user's username from storage
      final storage = await StorageService.getInstance();
      final userJson = await storage.read(key: AppConstants.userKey);

      if (userJson == null) {
        final posts = Post.getMockPosts();
        emit(PostLoaded(posts: posts));
        return;
      }

      final user = api_models.User.fromJson(json.decode(userJson));

      // Fetch posts from followed users
      final apiPosts = await _apiService.getFollowedPosts(user.username);

      // Convert API posts to UI posts
      final posts = apiPosts.map((apiPost) => _convertApiPostToUiPost(apiPost)).toList();

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

  Future<void> _onPostYeahToggled(
    PostYeahToggled event,
    Emitter<PostState> emit,
  ) async {
    if (state is! PostLoaded) return;

    final currentState = state as PostLoaded;

    // Optimistically update UI
    final updatedPosts = currentState.posts.map((post) {
      if (post.id == event.postId) {
        return post.copyWith(
          isYeahed: !post.isYeahed,
          yeahCount: post.isYeahed ? post.yeahCount - 1 : post.yeahCount + 1,
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

        // Update with actual API response
        final finalPosts = updatedPosts.map((post) {
          if (post.id == event.postId) {
            return _convertApiPostToUiPost(updatedPost);
          }
          return post;
        }).toList();

        emit(PostLoaded(posts: finalPosts));
      }
    } on DioException catch (e) {
      debugPrint('API Error toggling yeah: ${e.message}');
      // Keep optimistic update if API fails
    } catch (e) {
      debugPrint('Error toggling yeah: $e');
      // Keep optimistic update if API fails
    }
  }

  Post _convertApiPostToUiPost(api_models.Post apiPost) {
    return Post(
      id: apiPost.id.toString(),
      userId: apiPost.authorUsername,
      username: apiPost.authorUsername,
      avatarUrl: null, // API doesn't provide avatar in post response
      imageUrl: apiPost.picture,
      caption: apiPost.caption,
      theme: apiPost.theme,
      yeahCount: apiPost.yeahCount,
      commentCount: apiPost.comments.length,
      createdAt: apiPost.createdAt,
      streakDay: 1, // Calculate from user's posting history
      isYeahed: false, // Would need to check against current user's yeahs
    );
  }
}
