import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'package:inkstreak/data/models/user_models.dart' as api_models;
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/core/utils/user_id_provider.dart';
import 'package:inkstreak/core/utils/post_mapper.dart';
import 'package:inkstreak/core/constants/constants.dart';
import 'dart:convert';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final ApiService _apiService;
  int? _currentUserId;

  CalendarBloc({required ApiService apiService})
      : _apiService = apiService,
        super(CalendarState()) {
    on<CalendarMonthChanged>(_onMonthChanged);
    on<CalendarMonthIncremented>(_onMonthIncremented);
    on<CalendarMonthDecremented>(_onMonthDecremented);
    on<CalendarPostsLoadRequested>(_onPostsLoadRequested);
    on<CalendarDaySelected>(_onDaySelected);
    _initUserId();
  }

  Future<void> _initUserId() async {
    _currentUserId = await UserIdProvider.getCurrentUserId();
  }

  void _onMonthChanged(
    CalendarMonthChanged event,
    Emitter<CalendarState> emit,
  ) {
    emit(state.copyWith(focusedMonth: event.month));
  }

  void _onMonthIncremented(
    CalendarMonthIncremented event,
    Emitter<CalendarState> emit,
  ) {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month + 1,
      1,
    );
    emit(state.copyWith(focusedMonth: newMonth));
  }

  void _onMonthDecremented(
    CalendarMonthDecremented event,
    Emitter<CalendarState> emit,
  ) {
    final newMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month - 1,
      1,
    );
    emit(state.copyWith(focusedMonth: newMonth));
  }

  Future<void> _onPostsLoadRequested(
    CalendarPostsLoadRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(
      status: CalendarStatus.loading,
      username: event.username,
    ));

    if (_currentUserId == null) {
      _currentUserId = await UserIdProvider.getCurrentUserId();
    }

    try {
      // Fetch all posts
      final apiPosts = await _apiService.getAllPosts();

      final userPosts = apiPosts
          .where((post) => post.author.username == event.username)
          .toList();

      final Map<DateTime, List<Post>> postsByDate = {};
      final Set<DateTime> daysWithPosts = {};
      final Set<DateTime> streakDays = {};

      for (final apiPost in userPosts) {
        final date = DateTime(
          apiPost.createdAt.year,
          apiPost.createdAt.month,
          apiPost.createdAt.day,
        );

        final post = PostMapper.fromApiPost(apiPost, currentUserId: _currentUserId);

        if (!postsByDate.containsKey(date)) {
          postsByDate[date] = [];
        }
        postsByDate[date]!.add(post);

        // Mark this day as having posts
        daysWithPosts.add(date);

        // Mark as streak day if the post has a streak (artistStreak > 0)
        if (apiPost.artistStreak > 0) {
          streakDays.add(date);
        }
      }

      emit(state.copyWith(
        status: CalendarStatus.success,
        postsByDate: postsByDate,
        daysWithPosts: daysWithPosts,
        streakDays: streakDays,
        focusedMonth: event.month,
      ));
    } on DioException catch (e) {
      debugPrint('API Error loading calendar posts: ${e.message}');
    } catch (e) {
      emit(state.copyWith(
        status: CalendarStatus.failure,
        errorMessage: 'Failed to load calendar posts: $e',
      ));
    }
  }

  void _onDaySelected(
    CalendarDaySelected event,
    Emitter<CalendarState> emit,
  ) {
    emit(state.copyWith(selectedDay: event.day));
  }

}
