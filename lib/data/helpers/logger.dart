import 'package:logger/logger.dart' as log;

class Logger {
  final String tag;
  final log.Logger _logger = log.Logger(
    printer: log.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  Logger([this.tag = 'App']);

  void info(String message) {
    _logger.i('[$tag] $message');
  }

  void debug(String message) {
    _logger.d('[$tag] $message');
  }

  void warning(String message) {
    _logger.w('[$tag] $message');
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(
      '[$tag] $message',
      error: error,
      stackTrace: stackTrace,
    );
  }
} 