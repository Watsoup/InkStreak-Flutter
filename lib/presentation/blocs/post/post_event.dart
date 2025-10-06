import 'package:equatable/equatable.dart';

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

class PostYeahToggled extends PostEvent {
  final String postId;

  const PostYeahToggled({required this.postId});

  @override
  List<Object?> get props => [postId];
}
