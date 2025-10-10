import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ApiService _apiService;

  ThemeBloc()
      : _apiService = ApiService(DioClient.createDio()),
        super(const ThemeInitial()) {
    on<ThemeLoadRequested>(_onThemeLoadRequested);
    on<ThemeRefreshRequested>(_onThemeRefreshRequested);
  }

  Future<void> _onThemeLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    emit(const ThemeLoading());

    try {
      final theme = await _apiService.getCurrentTheme();
      emit(ThemeLoaded(theme: theme));
    } on DioException catch (e) {
      debugPrint('API Error loading theme: ${e.message}');
      emit(ThemeError(message: 'Failed to load theme: ${e.message}'));
    } catch (e) {
      emit(ThemeError(message: 'Failed to load theme: $e'));
    }
  }

  Future<void> _onThemeRefreshRequested(
    ThemeRefreshRequested event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final theme = await _apiService.getCurrentTheme();
      emit(ThemeLoaded(theme: theme));
    } on DioException catch (e) {
      debugPrint('API Error refreshing theme: ${e.message}');
      // Keep current state if refresh fails
      if (state is! ThemeLoaded) {
        emit(ThemeError(message: 'Failed to refresh theme: ${e.message}'));
      }
    } catch (e) {
      if (state is! ThemeLoaded) {
        emit(ThemeError(message: 'Failed to refresh theme: $e'));
      }
    }
  }
}
