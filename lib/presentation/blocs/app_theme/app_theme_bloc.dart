import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkstreak/core/utils/storage_service.dart';
import 'app_theme_event.dart';
import 'app_theme_state.dart';

class AppThemeBloc extends Bloc<AppThemeEvent, AppThemeState> {
  static const String _themeKey = 'theme_mode';

  AppThemeBloc() : super(const AppThemeState(isDarkMode: false)) {
    on<LoadThemePreference>(_onLoadThemePreference);
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);
  }

  Future<void> _onLoadThemePreference(
    LoadThemePreference event,
    Emitter<AppThemeState> emit,
  ) async {
    try {
      final storage = await StorageService.getInstance();
      final themeMode = await storage.read(key: _themeKey);
      final isDarkMode = themeMode == 'dark';
      emit(AppThemeState(isDarkMode: isDarkMode));
    } catch (e) {
      // If there's an error loading, default to light mode
      emit(const AppThemeState(isDarkMode: false));
    }
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<AppThemeState> emit,
  ) async {
    final newDarkMode = !state.isDarkMode;
    emit(AppThemeState(isDarkMode: newDarkMode));
    await _saveThemePreference(newDarkMode);
  }

  Future<void> _onSetTheme(
    SetTheme event,
    Emitter<AppThemeState> emit,
  ) async {
    emit(AppThemeState(isDarkMode: event.isDarkMode));
    await _saveThemePreference(event.isDarkMode);
  }

  Future<void> _saveThemePreference(bool isDarkMode) async {
    try {
      final storage = await StorageService.getInstance();
      await storage.write(
        key: _themeKey,
        value: isDarkMode ? 'dark' : 'light',
      );
    } catch (e) {
      // Silently fail if we can't save the preference
    }
  }
}
