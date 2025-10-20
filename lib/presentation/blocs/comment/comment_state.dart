import 'package:equatable/equatable.dart';
import 'package:inkstreak/data/models/user_models.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {
  const CommentInitial();
}

class CommentLoading extends CommentState {
  const CommentLoading();
}

/// State for when comments are loaded
class CommentsLoaded extends CommentState {
  final int postId;
  final List<Comment> comments;

  const CommentsLoaded({
    required this.postId,
    required this.comments,
  });

  @override
  List<Object?> get props => [postId, comments];
}

/// State for when adding a comment (optimistic update)
class CommentAdding extends CommentState {
  final int postId;
  final List<Comment> comments;
  final String pendingContent;

  const CommentAdding({
    required this.postId,
    required this.comments,
    required this.pendingContent,
  });

  @override
  List<Object?> get props => [postId, comments, pendingContent];
}

class CommentError extends CommentState {
  final String message;
  final int? postId;

  const CommentError({
    required this.message,
    this.postId,
  });

  @override
  List<Object?> get props => [message, postId];
}
