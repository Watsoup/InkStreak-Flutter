import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:inkstreak/presentation/blocs/calendar/calendar_bloc.dart';
import 'package:inkstreak/presentation/blocs/calendar/calendar_event.dart';
import 'package:inkstreak/presentation/blocs/calendar/calendar_state.dart';
import 'package:inkstreak/presentation/widgets/calendar/month_navigation_widget.dart';

class ProfileCalendarWidget extends StatefulWidget {
  final String username;

  const ProfileCalendarWidget({
    super.key,
    required this.username,
  });

  @override
  State<ProfileCalendarWidget> createState() => _ProfileCalendarWidgetState();
}

class _ProfileCalendarWidgetState extends State<ProfileCalendarWidget> {
  @override
  void initState() {
    super.initState();
    // Load posts for the current month when widget is created
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    context.read<CalendarBloc>().add(
          CalendarPostsLoadRequested(
            username: widget.username,
            month: currentMonth,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            children: [
              // Month navigation
              MonthNavigationWidget(
              focusedMonth: state.focusedMonth,
              onPreviousMonth: () {
                context.read<CalendarBloc>().add(const CalendarMonthDecremented());
                // Reload posts for new month
                final newMonth = DateTime(
                  state.focusedMonth.year,
                  state.focusedMonth.month - 1,
                  1,
                );
                context.read<CalendarBloc>().add(
                      CalendarPostsLoadRequested(
                        username: widget.username,
                        month: newMonth,
                      ),
                    );
              },
              onNextMonth: () {
                context.read<CalendarBloc>().add(const CalendarMonthIncremented());
                // Reload posts for new month
                final newMonth = DateTime(
                  state.focusedMonth.year,
                  state.focusedMonth.month + 1,
                  1,
                );
                context.read<CalendarBloc>().add(
                      CalendarPostsLoadRequested(
                        username: widget.username,
                        month: newMonth,
                      ),
                    );
              },
            ),

            const SizedBox(height: 16),

            // Loading indicator
            if (state.status == CalendarStatus.loading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),

            // Error message
            if (state.status == CalendarStatus.failure)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.errorMessage ?? 'Failed to load calendar',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),

            // Calendar
            if (state.status == CalendarStatus.success)
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  firstDay: DateTime(2020, 1, 1),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: state.focusedMonth,
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,

                  // Header is hidden since we use custom MonthNavigationWidget
                  headerVisible: false,

                  // Calendar style
                  calendarStyle: CalendarStyle(
                    // Today's date
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),

                    // Default days
                    defaultTextStyle: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),

                    // Weekend days
                    weekendTextStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),

                    // Outside month days
                    outsideTextStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),

                    // Disabled days (future dates, days without posts)
                    disabledTextStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),

                  // Days of week style (Mon, Tue, etc.)
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Determine which days are enabled (only days with posts)
                  enabledDayPredicate: (day) {
                    final normalizedDay = DateTime(day.year, day.month, day.day);
                    return state.daysWithPosts.contains(normalizedDay);
                  },

                  // Custom day builder to show flame emoji for streak days
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildDayCell(context, day, state, theme);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildDayCell(context, day, state, theme, isToday: true);
                    },
                    outsideBuilder: (context, day, focusedDay) {
                      return _buildDayCell(context, day, state, theme, isOutside: true);
                    },
                    disabledBuilder: (context, day, focusedDay) {
                      return _buildDayCell(context, day, state, theme, isDisabled: true);
                    },
                  ),

                  // Handle day selection
                  onDaySelected: (selectedDay, focusedDay) {
                    final normalizedDay = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                    );

                    // Only navigate if the day has posts
                    if (state.daysWithPosts.contains(normalizedDay)) {
                      context.read<CalendarBloc>().add(CalendarDaySelected(normalizedDay));

                      // Navigate to day posts screen
                      context.push(
                        '/day-posts',
                        extra: {
                          'date': normalizedDay,
                          'posts': state.postsByDate[normalizedDay] ?? [],
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    CalendarState state,
    ThemeData theme, {
    bool isToday = false,
    bool isOutside = false,
    bool isDisabled = false,
  }) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final hasPost = state.daysWithPosts.contains(normalizedDay);
    final isStreakDay = state.streakDays.contains(normalizedDay);
    final dayPosts = state.postsByDate[normalizedDay];
    final imageUrl = dayPosts != null && dayPosts.isNotEmpty
        ? dayPosts.first.imageUrl
        : null;

    Color textColor;
    Color? backgroundColor;
    Color? borderColor;

    if (isToday) {
      textColor = Colors.white;
      backgroundColor = hasPost ? null : theme.colorScheme.primary.withValues(alpha: 0.3);
      borderColor = theme.colorScheme.primary;
    } else if (isDisabled || !hasPost) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
      backgroundColor = null;
      borderColor = null;
    } else if (isOutside) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
      backgroundColor = null;
      borderColor = null;
    } else {
      textColor = Colors.white;
      backgroundColor = null;
      borderColor = null;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 2)
            : null,
      ),
      child: hasPost && imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image preview
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  // Dark overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                  // Date and flame emoji
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        if (isStreakDay)
                          const Text(
                            '🔥',
                            style: TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: hasPost ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  if (isStreakDay)
                    const Text(
                      '🔥',
                      style: TextStyle(fontSize: 10),
                    ),
                ],
              ),
            ),
    );
  }
}
