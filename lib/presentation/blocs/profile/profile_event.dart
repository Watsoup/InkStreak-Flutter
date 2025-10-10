import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfilePictureUpdateRequested extends ProfileEvent {
  final File picture;

  const ProfilePictureUpdateRequested({required this.picture});

  @override
  List<Object?> get props => [picture];
}

class ProfileUpdateRequested extends ProfileEvent {
  final String? bio;

  const ProfileUpdateRequested({this.bio});

  @override
  List<Object?> get props => [bio];
}

class ProfilePictureRemoveRequested extends ProfileEvent {
  const ProfilePictureRemoveRequested();
}
