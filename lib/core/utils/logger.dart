import 'package:logger/logger.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  late Logger _logger;

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal() {
    _logger = Logger(filter: DevelopmentFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }

  static void debug(dynamic message) {
    _instance._logger.d(message);
  }

  static void info(dynamic message) {
    _instance._logger.i(message);
  }

  static void warning(dynamic message) {
    _instance._logger.w(message);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _instance._logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _instance._logger.f(message, error: error, stackTrace: stackTrace);
  }

  static void trace(dynamic message) {
    _instance._logger.t(message);
  }
}
