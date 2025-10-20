import 'package:equatable/equatable.dart';
import 'package:inkstreak/presentation/blocs/post/post_filters.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class PostLoadRequested extends PostEvent {
  const PostLoadRequested();
}

class PostRefreshRequested extends PostEvent {
  const PostRefreshRequested();
}

class PostLoadByFilter extends PostEvent {
  final FeedType feedType;
  final SortType sortType;
  final TimePeriod timePeriod;

  const PostLoadByFilter({
    required this.feedType,
    required this.sortType,
    required this.timePeriod,
  });

  @override
  List<Object?> get props => [feedType, sortType, timePeriod];
}

class PostYeahToggled extends PostEvent {
  final String postId;

  const PostYeahToggled({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class PostCommentCountUpdated extends PostEvent {
  final String postId;
  final int commentCount;

  const PostCommentCountUpdated({
    required this.postId,
    required this.commentCount,
  });

  @override
  List<Object?> get props => [postId, commentCount];
}
