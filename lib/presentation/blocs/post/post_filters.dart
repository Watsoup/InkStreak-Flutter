enum FeedType {
  everyone,
  followed,
}

enum SortType {
  random,
  best,
}

enum TimePeriod {
  today,
  yesterday,
  thisMonth,
  allTime,
}

extension TimePeriodExtension on TimePeriod {
  String get displayName {
    switch (this) {
      case TimePeriod.today:
        return 'Today';
      case TimePeriod.yesterday:
        return 'Yesterday';
      case TimePeriod.thisMonth:
        return 'This Month';
      case TimePeriod.allTime:
        return 'All Time';
    }
  }

  DateTimeRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case TimePeriod.today:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
      case TimePeriod.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: yesterday,
          end: today,
        );
      case TimePeriod.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        return DateTimeRange(
          start: monthStart,
          end: today.add(const Duration(days: 1)),
        );
      case TimePeriod.allTime:
        return DateTimeRange(
          start: DateTime(2000, 1, 1), // Far past date
          end: today.add(const Duration(days: 1)),
        );
    }
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});
}
