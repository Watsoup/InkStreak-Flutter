// Universal file abstraction for cross-platform compatibility
export 'universal_file_stub.dart'
    if (dart.library.io) 'universal_file_io.dart'
    if (dart.library.html) 'universal_file_web.dart';
