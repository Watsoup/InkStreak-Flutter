class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App general constants
  static const String appName = 'InkStreak';
  static const String appVersion = '1.0.0';

  // API related constants
  // Toggle this flag to switch between local and production API
  static const bool useLocalApi = false;

  static const String _localBaseUrl = 'http://localhost:7777/inkstreak/';
  static const String _productionBaseUrl = 'https://api.watsoup.tech/inkstreak/';

  static const String baseUrl = useLocalApi ? _localBaseUrl : _productionBaseUrl;
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