import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../utils/storage_service.dart';
import '../constants/constants.dart';

class UserIdProvider {
  static Future<int?> getCurrentUserId() async {
    try {
      final storage = await StorageService.getInstance();

      final token = await storage.read(key: AppConstants.tokenKey);
      if (token != null) {
        try {
          final decodedToken = JwtDecoder.decode(token);
          final userId = decodedToken['id'];

          if (userId is int) {
            return userId;
          } else if (userId is String) {
            final parsedId = int.tryParse(userId);
            if (parsedId != null) {
              return parsedId;
            }
          }
        } catch (e) {
          // Token decode failed, try fallback
        }
      }

      final userJson = await storage.read(key: AppConstants.userKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final userId = userMap['id'];

        if (userId is int) {
          return userId;
        } else if (userId is String) {
          return int.tryParse(userId);
        }
      }
    } catch (e) {
      return null;
    }

    return null;
  }
}
