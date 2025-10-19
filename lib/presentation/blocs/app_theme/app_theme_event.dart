import 'package:equatable/equatable.dart';

abstract class AppThemeEvent extends Equatable {
  const AppThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadThemePreference extends AppThemeEvent {
  const LoadThemePreference();
}

class ToggleTheme extends AppThemeEvent {
  const ToggleTheme();
}

class SetTheme extends AppThemeEvent {
  final bool isDarkMode;

  const SetTheme({required this.isDarkMode});

  @override
  List<Object?> get props => [isDarkMode];
}
