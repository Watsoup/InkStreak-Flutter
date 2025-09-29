import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<void> write({required String key, required String value}) async {
    await _preferences!.setString(key, value);
  }

  Future<String?> read({required String key}) async {
    return _preferences!.getString(key);
  }

  Future<void> delete({required String key}) async {
    await _preferences!.remove(key);
  }

  Future<void> deleteAll() async {
    await _preferences!.clear();
  }
}