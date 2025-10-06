import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class PostActions extends StatefulWidget {
  final bool isYeahed;
  final int yeahCount;
  final int commentCount;
  final VoidCallback onYeahTap;
  final VoidCallback onCommentTap;

  const PostActions({
    super.key,
    required this.isYeahed,
    required this.yeahCount,
    required this.commentCount,
    required this.onYeahTap,
    required this.onCommentTap,
  });

  @override
  State<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<PostActions> {
  late ConfettiController _confettiController;
  final GlobalKey _yeahButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleYeahTap() {
    // Only play confetti when yeahing (not unyeahing)
    if (!widget.isYeahed) {
      _confettiController.play();
    }
    widget.onYeahTap();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    key: _yeahButtonKey,
                    onPressed: _handleYeahTap,
                    icon: Image.asset(
                      widget.isYeahed
                          ? 'assets/images/yeah_active.png'
                          : 'assets/images/yeah_inactive.png',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to material icon if asset not found
                        return Icon(
                          widget.isYeahed ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: widget.isYeahed ? Colors.blue : Colors.grey[700],
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 10,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirection: -pi / 2, // upward
                      emissionFrequency: 0.1,
                      numberOfParticles: 5,
                      gravity: 0.4,
                      shouldLoop: false,
                      maxBlastForce: 10,
                      minBlastForce: 5,
                      blastDirectionality: BlastDirectionality.explosive,
                      colors: const [
                        Color(0xFF32CD32), // Lime green
                        Color(0xFF3FE03F),
                        Color(0xFF28B828),
                        Color(0xFF25A525),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.yeahCount}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: widget.onCommentTap,
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${widget.commentCount}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share feature coming soon!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: Icon(
                  Icons.share_outlined,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
