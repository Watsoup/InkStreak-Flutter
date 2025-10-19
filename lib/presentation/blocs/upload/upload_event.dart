import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

class UploadCheckStatus extends UploadEvent {
  const UploadCheckStatus();
}

class UploadImageSelected extends UploadEvent {
  final XFile image;

  const UploadImageSelected({required this.image});

  @override
  List<Object?> get props => [image];
}

class UploadCaptionChanged extends UploadEvent {
  final String caption;

  const UploadCaptionChanged({required this.caption});

  @override
  List<Object?> get props => [caption];
}

class UploadSubmitted extends UploadEvent {
  const UploadSubmitted();
}

class UploadReset extends UploadEvent {
  const UploadReset();
}

class UploadSuccessAcknowledged extends UploadEvent {
  const UploadSuccessAcknowledged();
}
