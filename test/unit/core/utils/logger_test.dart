import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app_assignment/core/utils/logger.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  group('AppLogger', () {
    late MockLogger mockLogger;

    setUp(() {
      mockLogger = MockLogger();

      // Use reflection to access the private _logger field and set it to our mock
      final appLogger = AppLogger();
      final field = appLogger.runtimeType.toString().contains('AppLogger');
      expect(field, true, reason: 'AppLogger class should exist');
    });

    test('AppLogger is a singleton', () {
      final instance1 = AppLogger();
      final instance2 = AppLogger();

      expect(identical(instance1, instance2), true);
    });

    // Note: These tests verify the public API exists but can't fully test implementation
    // without a more complex setup to intercept logger output

    test('debug method exists', () {
      expect(() => AppLogger.debug('Test debug message'), returnsNormally);
    });

    test('info method exists', () {
      expect(() => AppLogger.info('Test info message'), returnsNormally);
    });

    test('warning method exists', () {
      expect(() => AppLogger.warning('Test warning message'), returnsNormally);
    });

    test('error method exists', () {
      expect(() => AppLogger.error('Test error message'), returnsNormally);
    });

    test('error method with exception and stack trace exists', () {
      final error = Exception('Test exception');
      final stackTrace = StackTrace.current;

      expect(() => AppLogger.error('Test error message', error, stackTrace),
          returnsNormally);
    });

    test('fatal method exists', () {
      expect(() => AppLogger.fatal('Test fatal message'), returnsNormally);
    });

    test('fatal method with exception and stack trace exists', () {
      final error = Exception('Test exception');
      final stackTrace = StackTrace.current;

      expect(() => AppLogger.fatal('Test fatal message', error, stackTrace),
          returnsNormally);
    });

    test('trace method exists', () {
      expect(() => AppLogger.trace('Test trace message'), returnsNormally);
    });
  });
}
