import 'package:equatable/equatable.dart';

abstract class FollowState extends Equatable {
  const FollowState();

  @override
  List<Object?> get props => [];
}

class FollowInitial extends FollowState {
  const FollowInitial();
}

class FollowLoading extends FollowState {
  const FollowLoading();
}

/// State for follow status of a specific user
class FollowStatusLoaded extends FollowState {
  final String username;
  final bool isFollowing;
  final int followerCount;
  final int followingCount;

  const FollowStatusLoaded({
    required this.username,
    required this.isFollowing,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  @override
  List<Object?> get props => [username, isFollowing, followerCount, followingCount];

  FollowStatusLoaded copyWith({
    String? username,
    bool? isFollowing,
    int? followerCount,
    int? followingCount,
  }) {
    return FollowStatusLoaded(
      username: username ?? this.username,
      isFollowing: isFollowing ?? this.isFollowing,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}

/// State for toggling follow status (optimistic update in progress)
class FollowToggling extends FollowState {
  final String username;
  final bool targetIsFollowing;
  final int followerCount;
  final int followingCount;

  const FollowToggling({
    required this.username,
    required this.targetIsFollowing,
    required this.followerCount,
    required this.followingCount,
  });

  @override
  List<Object?> get props => [username, targetIsFollowing, followerCount, followingCount];
}

/// State for displaying list of followers/following
class FollowListLoaded extends FollowState {
  final String username;
  final List<String> usernames;
  final FollowListType listType;

  const FollowListLoaded({
    required this.username,
    required this.usernames,
    required this.listType,
  });

  @override
  List<Object?> get props => [username, usernames, listType];
}

enum FollowListType {
  followers,
  following,
}

class FollowError extends FollowState {
  final String message;
  final String? username;

  const FollowError({
    required this.message,
    this.username,
  });

  @override
  List<Object?> get props => [message, username];
}
