import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inkstreak/data/models/post_models.dart';

abstract class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object?> get props => [];
}

class UploadInitial extends UploadState {
  const UploadInitial();
}

class UploadReady extends UploadState {
  final bool hasPostedToday;
  final Post? todaysPost;
  final String todaysTheme;
  final String? themeDescription;
  final Duration timeUntilNextTheme;

  const UploadReady({
    required this.hasPostedToday,
    this.todaysPost,
    required this.todaysTheme,
    this.themeDescription,
    required this.timeUntilNextTheme,
  });

  @override
  List<Object?> get props => [hasPostedToday, todaysPost, todaysTheme, themeDescription, timeUntilNextTheme];
}

class UploadImagePicked extends UploadState {
  final XFile image;
  final String caption;
  final String todaysTheme;
  final String? themeDescription;
  final Duration timeUntilNextTheme;

  const UploadImagePicked({
    required this.image,
    this.caption = '',
    required this.todaysTheme,
    this.themeDescription,
    required this.timeUntilNextTheme,
  });

  UploadImagePicked copyWith({
    XFile? image,
    String? caption,
    String? todaysTheme,
    String? themeDescription,
    Duration? timeUntilNextTheme,
  }) {
    return UploadImagePicked(
      image: image ?? this.image,
      caption: caption ?? this.caption,
      todaysTheme: todaysTheme ?? this.todaysTheme,
      themeDescription: themeDescription ?? this.themeDescription,
      timeUntilNextTheme: timeUntilNextTheme ?? this.timeUntilNextTheme,
    );
  }

  @override
  List<Object?> get props => [image, caption, todaysTheme, themeDescription, timeUntilNextTheme];
}

class UploadInProgress extends UploadState {
  final XFile image;
  final String caption;

  const UploadInProgress({
    required this.image,
    required this.caption,
  });

  @override
  List<Object?> get props => [image, caption];
}

class UploadSuccess extends UploadState {
  final Post post;

  const UploadSuccess({required this.post});

  @override
  List<Object?> get props => [post];
}

class UploadError extends UploadState {
  final String message;

  const UploadError({required this.message});

  @override
  List<Object?> get props => [message];
}
