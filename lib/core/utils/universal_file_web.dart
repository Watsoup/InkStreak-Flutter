// Web implementation - File class that wraps XFile for web compatibility
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class File {
  final XFile _xFile;

  File(String path) : _xFile = XFile(path);

  File.fromXFile(XFile xFile) : _xFile = xFile;

  String get path => _xFile.path;

  Future<Uint8List> readAsBytes() => _xFile.readAsBytes();

  String get name => _xFile.name;

  XFile get xFile => _xFile;
}

// Helper function to create File from XFile (matches mobile API)
File createFileFromXFile(XFile xFile) {
  return File.fromXFile(xFile);
}
