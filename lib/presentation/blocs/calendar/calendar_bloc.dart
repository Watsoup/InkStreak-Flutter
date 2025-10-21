import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'package:inkstreak/data/models/user_models.dart' as api_models;
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/core/utils/storage_service.dart';
import 'package:inkstreak/core/constants/constants.dart';
import 'dart:convert';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final ApiService _apiService;
  int? _currentUserId;

  CalendarBloc()
      : _apiService = ApiService(DioClient.createDio()),
        super(CalendarState()) {
    on<CalendarMonthChanged>(_onMonthChanged);
    on<CalendarMonthIncremented>(_onMonthIncremented);
    on<CalendarMonthDecremented>(_onMonthDecremented);
    on<CalendarPostsLoadRequested>(_onPostsLoadRequested);
    on<CalendarDaySelected>(_onDaySelected);
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final storage = await StorageService.getInstance();

      // Try to get user ID from JWT token first (most reliable)
      final token = await storage.read(key: AppConstants.tokenKey);
      if (token != null) {
        try {
          final decodedToken = JwtDecoder.decode(token);
          final userId = decodedToken['id'];

          if (userId is int) {
            _currentUserId = userId;
            return;
          } else if (userId is String) {
            _currentUserId = int.tryParse(userId);
            if (_currentUserId != null) {
              return;
            }
          }
        } catch (e) {
          debugPrint('Failed to decode JWT token: $e');
        }
      }

      // Fallback: try to get from stored user data
      final userJson = await storage.read(key: AppConstants.userKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final userId = userMap['id'];

        if (userId is int) {
          _currentUserId = userId;
        } else if (userId is String) {
          _currentUserId = int.tryParse(userId);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading current user ID: $e');
      debugPrint('Stack trace: $stackTrace');
    }
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

    // Ensure user ID is loaded before processing posts
    if (_currentUserId == null) {
      await _loadCurrentUserId();
    }

    try {
      // Fetch all posts
      final apiPosts = await _apiService.getAllPosts();

      // Filter posts for the specific user
      final userPosts = apiPosts
          .where((post) => post.author.username == event.username)
          .toList();

      // Organize posts by date (day precision)
      final Map<DateTime, List<Post>> postsByDate = {};
      final Set<DateTime> daysWithPosts = {};
      final Set<DateTime> streakDays = {};

      for (final apiPost in userPosts) {
        // Normalize date to day precision (remove time component)
        final date = DateTime(
          apiPost.createdAt.year,
          apiPost.createdAt.month,
          apiPost.createdAt.day,
        );

        // Convert API post to UI post
        final post = _convertApiPostToUiPost(apiPost);

        // Add to posts by date
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
      // Fallback to mock data for demonstration
      final mockPosts = Post.getMockPosts();
      final Map<DateTime, List<Post>> postsByDate = {};
      final Set<DateTime> daysWithPosts = {};
      final Set<DateTime> streakDays = {};

      for (final post in mockPosts) {
        final date = DateTime(
          post.createdAt.year,
          post.createdAt.month,
          post.createdAt.day,
        );

        if (!postsByDate.containsKey(date)) {
          postsByDate[date] = [];
        }
        postsByDate[date]!.add(post);
        daysWithPosts.add(date);

        if (post.streakDay > 0) {
          streakDays.add(date);
        }
      }

      emit(state.copyWith(
        status: CalendarStatus.success,
        postsByDate: postsByDate,
        daysWithPosts: daysWithPosts,
        streakDays: streakDays,
      ));
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

  Post _convertApiPostToUiPost(api_models.Post apiPost) {
    // Check if current user has yeahed this post
    final isYeahed =
        _currentUserId != null && apiPost.yeahs.contains(_currentUserId);

    return Post(
      id: apiPost.id.toString(),
      userId: apiPost.author.id.toString(),
      username: apiPost.author.username,
      avatarUrl: apiPost.author.profilePicture,
      imageUrl: apiPost.picture,
      caption: apiPost.caption,
      theme: apiPost.themeName,
      yeahCount: apiPost.yeahCount,
      commentCount: apiPost.commentCount,
      createdAt: apiPost.createdAt,
      streakDay: apiPost.artistStreak,
      isYeahed: isYeahed,
    );
  }
}
