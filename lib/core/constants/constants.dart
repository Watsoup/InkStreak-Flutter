class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App general constants
  static const String appName = 'InkStreak';
  static const String appVersion = '1.0.0';

  // API related constants
  static const String baseUrl = 'https://api.watsoup.tech/inkstreak/';
  static const int timeoutDuration = 15;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Asset paths
  static const String imagePath = 'assets/images/';
  static const String iconPath = 'assets/icons/';

  // Animation durations
  static const int shortAnimationDuration = 200; // milliseconds
  static const int normalAnimationDuration = 350; // milliseconds
  static const int longAnimationDuration = 500; // milliseconds

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultMargin = 16.0;
}