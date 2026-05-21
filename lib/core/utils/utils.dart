/// Utility Functions
///
/// Responsibility:
/// - Provide helper functions
/// - Common utilities used across the application
/// - Format and validation utilities

/// Logger utility for debugging
class Logger {
  static void info(String message) {
    print('[INFO] $message');
  }

  static void warning(String message) {
    print('[WARNING] $message');
  }

  static void error(String message, [StackTrace? stackTrace]) {
    print('[ERROR] $message');
    if (stackTrace != null) {
      print(stackTrace);
    }
  }
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
