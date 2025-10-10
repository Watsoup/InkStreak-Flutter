import 'package:equatable/equatable.dart';
import 'package:inkstreak/data/models/user_models.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final User user;

  const ProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileUpdating extends ProfileState {
  final User user;
  final double? uploadProgress;

  const ProfileUpdating({required this.user, this.uploadProgress});

  @override
  List<Object?> get props => [user, uploadProgress];
}

class ProfileError extends ProfileState {
  final String message;
  final User? user;

  const ProfileError({required this.message, this.user});

  @override
  List<Object?> get props => [message, user];
}
