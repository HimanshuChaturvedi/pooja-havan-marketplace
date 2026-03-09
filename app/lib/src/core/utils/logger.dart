import 'package:flutter/foundation.dart';

/// A lightweight logger for Bharat Pooja Setu.
/// Handles colorful console output and environment filtering.
class AppLogger {
  static void info(String message) {
    _log('🟢 [INFO] $message');
  }

  static void warn(String message) {
    _log('🟡 [WARN] $message');
  }

  static void error(String message, [dynamic error, StackTrace? stack]) {
    _log('🔴 [ERROR] $message');
    if (error != null) _log('   Details: $error');
    if (stack != null) _log('   Stack: $stack');
  }

  static void debug(String message) {
    if (kDebugMode) {
      _log('🔵 [DEBUG] $message');
    }
  }

  static void _log(String message) {
    // In a real app, you might use a package like 'logger'.
    // Here we use a clean print for lightweight infrastructure.
    debugPrint(message);
  }
}
