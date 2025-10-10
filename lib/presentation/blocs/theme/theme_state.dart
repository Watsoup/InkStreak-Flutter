import 'package:equatable/equatable.dart';
import 'package:inkstreak/data/models/user_models.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

class ThemeLoading extends ThemeState {
  const ThemeLoading();
}

class ThemeLoaded extends ThemeState {
  final Theme theme;

  const ThemeLoaded({required this.theme});

  @override
  List<Object?> get props => [theme];
}

class ThemeError extends ThemeState {
  final String message;

  const ThemeError({required this.message});

  @override
  List<Object?> get props => [message];
}
