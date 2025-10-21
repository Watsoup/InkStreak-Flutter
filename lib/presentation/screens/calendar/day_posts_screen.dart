import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'package:inkstreak/presentation/blocs/post/post_bloc.dart';
import 'package:inkstreak/presentation/blocs/post/post_event.dart';
import 'package:inkstreak/presentation/widgets/post/post_card.dart';

class DayPostsScreen extends StatelessWidget {
  final DateTime date;
  final List<Post> posts;

  const DayPostsScreen({
    super.key,
    required this.date,
    required this.posts,
  });

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _formatDate(date),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No posts on this day',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PostCard(
                    post: post,
                    onYeahTap: () {
                      context.read<PostBloc>().add(
                            PostYeahToggled(postId: post.id),
                          );
                    },
                    onCommentTap: () {
                      context.push('/comments/${post.id}');
                    },
                    onShareTap: () {
                      // Share functionality will be handled by PostCard
                    },
                  ),
                );
              },
            ),
    );
  }
}
