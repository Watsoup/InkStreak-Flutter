// Stub implementation - should never be used
import 'package:image_picker/image_picker.dart';

class File {
  File(String path) {
    throw UnsupportedError('File is not supported on this platform');
  }

  String get path => throw UnsupportedError('File is not supported on this platform');
}

// Helper function to create File from XFile
File createFileFromXFile(XFile xFile) {
  throw UnsupportedError('createFileFromXFile is not supported on this platform');
}
