// IO implementation for mobile platforms
import 'dart:io';
import 'package:image_picker/image_picker.dart';

export 'dart:io' show File;

// Helper function to create File from XFile
File createFileFromXFile(XFile xFile) {
  return File(xFile.path);
}
