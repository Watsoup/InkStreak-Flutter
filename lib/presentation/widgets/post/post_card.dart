import 'package:flutter/material.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'post_header.dart';
import 'post_image.dart';
import 'post_actions.dart';
import 'post_footer.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onYeahTap;
  final VoidCallback onCommentTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onYeahTap,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(
            username: post.username,
            avatarUrl: post.avatarUrl,
            createdAt: post.createdAt,
            streakDay: post.streakDay,
          ),
          PostImage(imageUrl: post.imageUrl),
          PostActions(
            isYeahed: post.isYeahed,
            yeahCount: post.yeahCount,
            commentCount: post.commentCount,
            onYeahTap: onYeahTap,
            onCommentTap: onCommentTap,
          ),
          PostFooter(
            caption: post.caption,
            theme: post.theme,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
