import 'package:equatable/equatable.dart';
import 'package:inkstreak/data/models/user_models.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String hashedPassword;

  const AuthLoginRequested({
    required this.username,
    required this.hashedPassword,
  });

  @override
  List<Object?> get props => [username, hashedPassword];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}

class AuthUserUpdated extends AuthEvent {
  final User user;

  const AuthUserUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}
