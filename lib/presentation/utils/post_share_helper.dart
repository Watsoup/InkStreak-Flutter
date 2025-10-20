import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'package:inkstreak/presentation/widgets/post/post_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PostHelper {
  static Future<void> sharePost(BuildContext context, Post post) async {
    final boundaryKey = GlobalKey();

    // Create an overlay entry with the exportable widget off-screen
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        left: -10000, // Position off-screen
        top: 0,
        child: Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(
            key: boundaryKey,
            child: Container(
              width: 400, // Fixed width for consistent rendering
              color: Colors.white, // ensures a clean background
              padding: const EdgeInsets.all(8),
              child: PostCard(
                post: post,
                onYeahTap: () {},
                onCommentTap: () {},
                onShareTap: () {}, // dummy
                isExporting: true, // Disable confetti and animations
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);

    // Wait for the widget to be fully built and painted
    await Future.delayed(Duration.zero);

    // Ensure the first frame is rendered
    await WidgetsBinding.instance.endOfFrame;

    // Additional delay to allow network images to load
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Failed to find RepaintBoundary');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final pngBytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/post_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          text: 'Check out this post from InkStreak!',
          files: [XFile(file.path)],
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error exporting post: $e');
      debugPrint('Stack trace: $stackTrace');

      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      overlay.remove();
    }
  }
}
