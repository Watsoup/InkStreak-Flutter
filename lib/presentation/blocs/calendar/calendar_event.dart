import 'package:equatable/equatable.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class CalendarMonthChanged extends CalendarEvent {
  final DateTime month;

  const CalendarMonthChanged(this.month);

  @override
  List<Object?> get props => [month];
}

class CalendarMonthIncremented extends CalendarEvent {
  const CalendarMonthIncremented();
}

class CalendarMonthDecremented extends CalendarEvent {
  const CalendarMonthDecremented();
}

class CalendarPostsLoadRequested extends CalendarEvent {
  final String username;
  final DateTime month;

  const CalendarPostsLoadRequested({
    required this.username,
    required this.month,
  });

  @override
  List<Object?> get props => [username, month];
}

class CalendarDaySelected extends CalendarEvent {
  final DateTime day;

  const CalendarDaySelected(this.day);

  @override
  List<Object?> get props => [day];
}
