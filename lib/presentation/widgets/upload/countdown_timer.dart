import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final Duration duration;
  final bool hasPostedToday;

  const CountdownTimer({
    super.key,
    required this.duration,
    required this.hasPostedToday,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Duration _remainingTime;
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;

    // Update timer every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
          if (_remainingTime.isNegative) {
            _remainingTime = Duration.zero;
            timer.cancel();
          }
        });
      }
    });

    // Blinking animation for warning state
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (_shouldBlink) {
      _blinkController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _blinkController.dispose();
    super.dispose();
  }

  bool get _shouldBlink {
    return !widget.hasPostedToday && _remainingTime.inHours < 4;
  }

  Color get _statusColor {
    if (widget.hasPostedToday) {
      return Colors.green;
    } else if (_remainingTime.inHours < 4) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  String get _statusText {
    if (widget.hasPostedToday) {
      return 'Posted today ✓';
    } else {
      return 'Not posted yet';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _blinkController,
                builder: (context, child) {
                  final opacity = _shouldBlink ? _blinkController.value : 1.0;
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor.withValues(alpha: opacity),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                _statusText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Next theme in:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                _formatDuration(_remainingTime),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _shouldBlink ? Colors.red : Colors.grey[800],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
