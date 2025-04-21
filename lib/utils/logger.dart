// lib/utils/logger.dart


class Logger {
  // Log levels
  static const int VERBOSE = 0;
  static const int DEBUG = 1;
  static const int INFO = 2;
  static const int WARNING = 3;
  static const int ERROR = 4;
  
  // Current log level - adjust this to control what gets logged
  static int _currentLevel = DEBUG;
  
  /// Set the minimum log level
  static void setLevel(int level) {
    _currentLevel = level;
  }
  
  /// Log a verbose message
  static void verbose(String message) {
    if (_currentLevel <= VERBOSE) {
      _log('VERBOSE', message);
    }
  }
  
  /// Log a debug message
  static void debug(String message) {
    if (_currentLevel <= DEBUG) {
      _log('DEBUG', message);
    }
  }
  
  /// Log an info message
  static void info(String message) {
    if (_currentLevel <= INFO) {
      _log('INFO', message);
    }
  }
  
  /// Log a warning message
  static void warning(String message) {
    if (_currentLevel <= WARNING) {
      _log('WARNING', message);
    }
  }
  
  /// Log an error message
  static void error(String message) {
    if (_currentLevel <= ERROR) {
      _log('ERROR', message);
    }
  }
  
  /// Internal logging method
  static void _log(String level, String message) {
    final timestamp = DateTime.now().toString().substring(0, 19);
    print('[$timestamp] $level: $message');
  }
}