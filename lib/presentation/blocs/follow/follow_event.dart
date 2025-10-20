import 'package:equatable/equatable.dart';

abstract class FollowEvent extends Equatable {
  const FollowEvent();

  @override
  List<Object?> get props => [];
}

/// Toggle follow/unfollow for a specific user
class FollowToggleRequested extends FollowEvent {
  final String username;

  const FollowToggleRequested({required this.username});

  @override
  List<Object?> get props => [username];
}

/// Check if the current user follows a specific user
class FollowStatusRequested extends FollowEvent {
  final String username;

  const FollowStatusRequested({required this.username});

  @override
  List<Object?> get props => [username];
}

/// Load the list of followers for a specific user
class FollowersListRequested extends FollowEvent {
  final String username;

  const FollowersListRequested({required this.username});

  @override
  List<Object?> get props => [username];
}

/// Load the list of users that a specific user follows
class FollowingListRequested extends FollowEvent {
  final String username;

  const FollowingListRequested({required this.username});

  @override
  List<Object?> get props => [username];
}
