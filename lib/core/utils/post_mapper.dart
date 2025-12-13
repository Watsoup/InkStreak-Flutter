import 'package:inkstreak/data/models/post_models.dart';
import 'package:inkstreak/data/models/user_models.dart' as api_models;

class PostMapper {
  static Post fromApiPost(
    api_models.Post apiPost, {
    int? currentUserId,
    Map<String, int>? commentCountCache,
  }) {
    final isYeahed = currentUserId != null && apiPost.yeahs.contains(currentUserId);
    final postId = apiPost.id.toString();
    final commentCount = commentCountCache?[postId] ?? apiPost.commentCount;

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
