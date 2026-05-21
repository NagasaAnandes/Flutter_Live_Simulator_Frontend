// Utility Functions
//
// Responsibility:
// - Provide helper functions
// - Common utilities used across the application
// - Format and validation utilities

import '../log/logger.dart';

// Logger utility for debugging that delegates to AppLogger
class AppUtilsLogger {
  static void info(String message) => AppLogger.i('[INFO] $message');
  static void warning(String message) => AppLogger.w('[WARNING] $message');
  static void error(String message, [StackTrace? stackTrace]) =>
      AppLogger.e('[ERROR] $message', null, stackTrace);
}

/// Formatter utilities
class Formatters {
  /// Format duration to MM:SS
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  /// Format price with currency
  static String formatPrice(double price, {String currency = '\$'}) {
    return '$currency${price.toStringAsFixed(2)}';
  }
}
