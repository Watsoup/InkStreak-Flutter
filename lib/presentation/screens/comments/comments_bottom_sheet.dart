import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:inkstreak/data/models/user_models.dart' hide Theme;
import 'package:inkstreak/presentation/blocs/comment/comment_bloc.dart';
import 'package:inkstreak/presentation/blocs/comment/comment_event.dart';
import 'package:inkstreak/presentation/blocs/comment/comment_state.dart';
import 'package:inkstreak/presentation/blocs/post/post_bloc.dart';
import 'package:inkstreak/presentation/blocs/post/post_event.dart';
import 'package:inkstreak/presentation/widgets/common/username_text.dart';

class CommentsBottomSheet extends StatefulWidget {
  final int postId;
  final String postAuthor;

  const CommentsBottomSheet({
    super.key,
    required this.postId,
    required this.postAuthor,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load comments when bottom sheet opens
    context.read<CommentBloc>().add(CommentsLoadRequested(postId: widget.postId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _submitComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    context.read<CommentBloc>().add(
      CommentAddRequested(
        postId: widget.postId,
        content: content,
      ),
    );

    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Comments list
          Expanded(
            child: BlocConsumer<CommentBloc, CommentState>(
              listener: (context, state) {
                if (state is CommentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // Don't auto-reload on error - let the user retry manually
                } else if (state is CommentsLoaded && state.postId == widget.postId) {
                  // Update the post's comment count in the PostBloc
                  context.read<PostBloc>().add(
                    PostCommentCountUpdated(
                      postId: widget.postId.toString(),
                      commentCount: state.comments.length,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is CommentLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CommentsLoaded || state is CommentAdding) {
                  final List<Comment> comments;
                  final String? pendingContent;

                  if (state is CommentAdding) {
                    comments = state.comments;
                    pendingContent = state.pendingContent;
                  } else {
                    comments = (state as CommentsLoaded).comments;
                    pendingContent = null;
                  }

                  final showPending = state is CommentAdding;

                  if (comments.isEmpty && !showPending) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No comments yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to comment!',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: comments.length + (showPending ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show pending comment at the end
                      if (showPending && index == comments.length) {
                        return _buildPendingCommentItem(pendingContent!);
                      }

                      final comment = comments[index];
                      return _buildCommentItem(comment);
                    },
                  );
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load comments',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CommentBloc>().add(
                            CommentsLoadRequested(postId: widget.postId),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Comment input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: comment.author.profilePicture != null
                ? NetworkImage(comment.author.profilePicture!)
                : null,
            child: comment.author.profilePicture == null
                ? Text(
                    comment.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: UsernameText(
                        username: comment.username,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(comment.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCommentItem(String content) {
    return Opacity(
      opacity: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Posting...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocusNode,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submitComment(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _submitComment,
              icon: Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.primary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
