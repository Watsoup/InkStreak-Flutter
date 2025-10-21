import 'package:equatable/equatable.dart';
import 'package:inkstreak/data/models/post_models.dart';

enum CalendarStatus { initial, loading, success, failure }

class CalendarState extends Equatable {
  final CalendarStatus status;
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final Map<DateTime, List<Post>> postsByDate;
  final Set<DateTime> daysWithPosts;
  final Set<DateTime> streakDays;
  final String? errorMessage;
  final String? username;

  CalendarState({
    this.status = CalendarStatus.initial,
    DateTime? focusedMonth,
    this.selectedDay,
    this.postsByDate = const {},
    this.daysWithPosts = const {},
    this.streakDays = const {},
    this.errorMessage,
    this.username,
  }) : focusedMonth = focusedMonth ?? DateTime(DateTime.now().year, DateTime.now().month, 1);

  CalendarState copyWith({
    CalendarStatus? status,
    DateTime? focusedMonth,
    DateTime? selectedDay,
    Map<DateTime, List<Post>>? postsByDate,
    Set<DateTime>? daysWithPosts,
    Set<DateTime>? streakDays,
    String? errorMessage,
    String? username,
  }) {
    return CalendarState(
      status: status ?? this.status,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDay: selectedDay ?? this.selectedDay,
      postsByDate: postsByDate ?? this.postsByDate,
      daysWithPosts: daysWithPosts ?? this.daysWithPosts,
      streakDays: streakDays ?? this.streakDays,
      errorMessage: errorMessage ?? this.errorMessage,
      username: username ?? this.username,
    );
  }

  @override
  List<Object?> get props => [
        status,
        focusedMonth,
        selectedDay,
        postsByDate,
        daysWithPosts,
        streakDays,
        errorMessage,
        username,
      ];
}
