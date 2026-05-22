// App Constants
//
// Responsibility:
// - Centralize constant values
// - Provide configuration values
// - Define magic numbers and string constants

import 'package:flutter/foundation.dart';

class AppConstants {
  // Socket configuration
  static String get socketServerUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    // Android emulator cannot reach host localhost directly.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }

  static const int socketReconnectDelay = 1000;
  static const int socketReconnectMaxAttempts = 999999;

  // Hive configuration
  static const String hiveBoxName = 'app_preferences';

  // App configuration
  static const String appName = 'Live Commerce Simulator';
  static const String appVersion = '1.0.0';

  // UI configuration
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
}
