/// App Constants
///
/// Responsibility:
/// - Centralize constant values
/// - Provide configuration values
/// - Define magic numbers and string constants

class AppConstants {
  // Socket configuration
  static const String socketServerUrl = 'http://localhost:3000';
  static const int socketReconnectDelay = 1000;
  static const int socketReconnectMaxAttempts = 5;

  // Hive configuration
  static const String hiveBoxName = 'app_preferences';

  // App configuration
  static const String appName = 'Live Commerce Simulator';
  static const String appVersion = '1.0.0';

  // UI configuration
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
}
