import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(const PostInitial()) {
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Load mock posts
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Reload mock posts
      final posts = Post.getMockPosts();
      emit(PostLoaded(posts: posts));
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
  }
}
