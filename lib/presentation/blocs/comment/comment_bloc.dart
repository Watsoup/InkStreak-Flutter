import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/data/models/user_models.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final ApiService _apiService;

  CommentBloc()
      : _apiService = ApiService(DioClient.createDio()),
        super(const CommentInitial()) {
    on<CommentsLoadRequested>(_onCommentsLoadRequested);
    on<CommentAddRequested>(_onCommentAddRequested);
    on<CommentsClearRequested>(_onCommentsClearRequested);
  }

  Future<void> _onCommentsLoadRequested(
    CommentsLoadRequested event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());

    try {
      final comments = await _apiService.getComments(event.postId);

      emit(CommentsLoaded(
        postId: event.postId,
        comments: comments,
      ));
    } on DioException catch (e) {
      debugPrint('API Error loading comments: ${e.message}');
      final errorMessage = _handleDioError(e);
      emit(CommentError(
        message: errorMessage,
        postId: event.postId,
      ));
    } catch (e) {
      debugPrint('Error loading comments: $e');
      emit(CommentError(
        message: 'Failed to load comments: $e',
        postId: event.postId,
      ));
    }
  }

  Future<void> _onCommentAddRequested(
    CommentAddRequested event,
    Emitter<CommentState> emit,
  ) async {
    // Get current comments list
    List<Comment> currentComments = [];
    if (state is CommentsLoaded) {
      final currentState = state as CommentsLoaded;
      if (currentState.postId == event.postId) {
        currentComments = List.from(currentState.comments);
      }
    }

    // Optimistic update - show comment being added
    emit(CommentAdding(
      postId: event.postId,
      comments: currentComments,
      pendingContent: event.content,
    ));

    try {
      // Call API to add comment
      final request = AddCommentRequest(content: event.content);
      await _apiService.addComment(event.postId, request);

      // Reload comments to get fresh data from server
      final comments = await _apiService.getComments(event.postId);

      emit(CommentsLoaded(
        postId: event.postId,
        comments: comments,
      ));
    } on DioException catch (e) {
      debugPrint('API Error adding comment: ${e.message}');
      final errorMessage = _handleDioError(e);

      // Revert to previous state on error
      emit(CommentsLoaded(
        postId: event.postId,
        comments: currentComments,
      ));

      // Then emit error
      emit(CommentError(
        message: errorMessage,
        postId: event.postId,
      ));
    } catch (e) {
      debugPrint('Error adding comment: $e');

      // Revert to previous state on error
      emit(CommentsLoaded(
        postId: event.postId,
        comments: currentComments,
      ));

      // Then emit error
      emit(CommentError(
        message: 'Failed to add comment: $e',
        postId: event.postId,
      ));
    }
  }

  Future<void> _onCommentsClearRequested(
    CommentsClearRequested event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentInitial());
  }

  String _handleDioError(DioException error) {
    if (error.response != null) {
      switch (error.response!.statusCode) {
        case 400:
          return 'Invalid request';
        case 401:
          return 'Unauthorized. Please log in again.';
        case 404:
          return 'Post not found';
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
