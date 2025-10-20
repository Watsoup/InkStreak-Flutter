import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

/// Load all comments for a specific post
class CommentsLoadRequested extends CommentEvent {
  final int postId;

  const CommentsLoadRequested({required this.postId});

  @override
  List<Object?> get props => [postId];
}

/// Add a new comment to a post
class CommentAddRequested extends CommentEvent {
  final int postId;
  final String content;

  const CommentAddRequested({
    required this.postId,
    required this.content,
  });

  @override
  List<Object?> get props => [postId, content];
}

/// Clear comments state
class CommentsClearRequested extends CommentEvent {
  const CommentsClearRequested();
}
