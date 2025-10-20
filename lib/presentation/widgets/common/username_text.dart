import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A widget that displays text with clickable usernames
/// Supports both plain usernames and @mentions
class UsernameText extends StatelessWidget {
  final String username;
  final TextStyle? style;
  final bool showAtSymbol;

  const UsernameText({
    super.key,
    required this.username,
    this.style,
    this.showAtSymbol = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = showAtSymbol ? '@$username' : username;
    final defaultStyle = style ?? Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return GestureDetector(
      onTap: () => _navigateToProfile(context, username),
      child: Text(
        displayText,
        style: defaultStyle?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context, String username) {
    context.push('/profile/$username');
  }
}

/// A widget that parses text for @mentions and makes them clickable
class MentionText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const MentionText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    final mentionStyle = defaultStyle?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    // Parse text for @mentions
    final spans = <TextSpan>[];
    final regex = RegExp(r'@(\w+)');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before the match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: defaultStyle,
        ));
      }

      // Add the clickable mention
      final username = match.group(1)!;
      spans.add(TextSpan(
        text: '@$username',
        style: mentionStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () => _navigateToProfile(context, username),
      ));

      lastMatchEnd = match.end;
    }

    // Add remaining text after the last match
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: defaultStyle,
      ));
    }

    // If no mentions found, just return plain text
    if (spans.isEmpty) {
      return Text(
        text,
        style: defaultStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }

  void _navigateToProfile(BuildContext context, String username) {
    context.push('/profile/$username');
  }
}
