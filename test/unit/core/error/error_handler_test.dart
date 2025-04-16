import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/core/error/AppError.dart';
import 'package:weather_app_assignment/core/error/error_handler.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';

void main() {
  group('ErrorHandler', () {
    group('handleError', () {
      test('should handle SocketException', () {
        // Arrange
        final error = SocketException('Failed to connect');

        // Act
        final result = ErrorHandler.handleError(error);

        // Assert
        expect(result, isA<AppError>());
        expect(result.title, 'Network Error');
        expect(result.message, 'Please check your internet connection');
        expect(result.errorCode, 'NETWORK_ERROR');
        expect(result.isNetworkException, true);
      });

      test('should handle TimeoutException', () {
        // Arrange
        final error = TimeoutException('Request timeout');

        // Act
        final result = ErrorHandler.handleError(error);

        // Assert
        expect(result, isA<AppError>());
        expect(result.title, 'Request Timeout');
        expect(result.message, 'The server took too long to respond');
        expect(result.errorCode, 'TIMEOUT_ERROR');
        expect(result.isNetworkException, true);
      });

      test('should handle FormatException', () {
        // Arrange
        final error = FormatException('Invalid format', 'bad input');

        // Act
        final result = ErrorHandler.handleError(error);

        // Assert
        expect(result, isA<AppError>());
        expect(result.title, 'Format Error');
        expect(result.message, 'Unable to process the data');
        expect(result.errorCode, 'FORMAT_ERROR');
        expect(result.debugMessage, 'Invalid format');
      });

      test('should handle JsonUnsupportedObjectError', () {
        // Arrange
        final unsupportedObject = Object();
        final error = JsonUnsupportedObjectError(unsupportedObject);

        // Act
        final result = ErrorHandler.handleError(error);

        // Assert
        expect(result, isA<AppError>());
        expect(result.title, 'Data Processing Error');
        expect(result.message, 'Unable to process server response');
        expect(result.errorCode, 'JSON_ERROR');
      });

      test('should handle DataException', () {
        // Arrange
        final error = DataException(
          message: 'API error',
          debugMessage: 'Detailed error info',
          serverCode: '500',
        );

        // Act
        final result = ErrorHandler.handleError(error);

        // Assert
        expect(result, isA<AppError>());
        expect(result.message, 'API error');
        expect(result.debugMessage, 'Detailed error info');
      });

      test('should handle PlatformException', () {
        // Arrange
        final error = PlatformException(
          code: 'TEST_ERROR',
          message: 'Platform error',
          details: 'Error details',
        );

        // Act
        final result = ErrorHandler.handleError(error);

        // Assert
        expect(result, isA<AppError>());
        expect(result.errorCode, 'TEST_ERROR');
        expect(result.message, 'Platform error');
      });

      test('should handle HttpException', () {
        // Arrange
        final error = HttpException('HTTP error occurred');

        // Act
        final result = ErrorHandler.handleError(error);

        // Assert
        expect(result, isA<AppError>());
        expect(result.title, 'Server Error');
        expect(result.message, 'HTTP error occurred');
        expect(result.errorCode, 'HTTP_ERROR');
      });

      test('should handle permission errors', () {
        // Arrange
        final error = Exception('Permission denied for this operation');

        // Act
        final result = ErrorHandler.handleError(error);

        // Assert
        expect(result, isA<AppError>());
        expect(result.title, 'Permission Error');
        expect(result.errorCode, 'PERMISSION_ERROR');
      });

      test('should handle authentication errors', () {
        // Arrange
        final error = Exception('Unauthorized access attempt');

        // Act
        final result = ErrorHandler.handleError(error);

        // Assert
        expect(result, isA<AppError>());
        expect(result.title, 'Authentication Error');
        expect(result.errorCode, 'AUTH_ERROR');
      });

      test('should handle general exceptions', () {
        // Arrange
        final error = Exception('Generic exception');
        final context = 'Weather API';

        // Act
        final result = ErrorHandler.handleError(error, context: context);

        // Assert
        expect(result, isA<AppError>());
        expect(result.title, 'Error');
        expect(result.message, 'An error occurred in Weather API');
        expect(result.errorCode, 'GENERIC_ERROR');
      });

      test('should handle unknown errors', () {
        // Arrange
        final error = 'Just a string error';

        // Act
        final result = ErrorHandler.handleError(error);

        // Assert
        expect(result, isA<AppError>());
        expect(result.title, 'Unknown Error');
        expect(result.message, 'Just a string error');
        expect(result.errorCode, 'UNKNOWN_ERROR');
      });

      test('should handle null errors', () {
        // Act
        final result = ErrorHandler.handleError(null);

        // Assert
        expect(result, isA<AppError>());
        expect(result.title, 'Unknown Error');
        expect(result.message, 'An unknown error occurred');
        expect(result.errorCode, 'UNKNOWN_ERROR');
      });
    });

    group('categorizeError', () {
      test('should categorize network errors', () {
        expect(ErrorHandler.categorizeError(SocketException('Network error')),
            ErrorCategory.network);
        expect(
            ErrorHandler.categorizeError(
                Exception('Network connection failed')),
            ErrorCategory.network);
      });

      test('should categorize authentication errors', () {
        expect(ErrorHandler.categorizeError(Exception('Unauthorized access')),
            ErrorCategory.authentication);
        expect(ErrorHandler.categorizeError(Exception('Invalid token')),
            ErrorCategory.authentication);
      });

      test('should categorize permission errors', () {
        expect(ErrorHandler.categorizeError(Exception('Permission denied')),
            ErrorCategory.permission);
        expect(
            ErrorHandler.categorizeError(
                Exception('Access denied to resource')),
            ErrorCategory.permission);
      });

      test('should categorize timeout errors', () {
        expect(
            ErrorHandler.categorizeError(TimeoutException('Request timeout')),
            ErrorCategory.timeout);
        expect(ErrorHandler.categorizeError(Exception('Operation timeout')),
            ErrorCategory.timeout);
      });

      test('should categorize format errors', () {
        expect(ErrorHandler.categorizeError(FormatException('Bad format')),
            ErrorCategory.format);
        expect(
            ErrorHandler.categorizeError(JsonUnsupportedObjectError(Object())),
            ErrorCategory.format);
      });

      test('should categorize server errors', () {
        expect(ErrorHandler.categorizeError(HttpException('Server error')),
            ErrorCategory.server);
        expect(
            ErrorHandler.categorizeError(DataException(message: 'API error')),
            ErrorCategory.server);
      });

      test('should categorize validation errors', () {
        expect(ErrorHandler.categorizeError(Exception('Invalid input')),
            ErrorCategory.validation);
        expect(ErrorHandler.categorizeError(Exception('Validation failed')),
            ErrorCategory.validation);
      });

      test('should categorize unknown errors', () {
        expect(ErrorHandler.categorizeError(Exception('Random error')),
            ErrorCategory.unknown);
        expect(ErrorHandler.categorizeError(null), ErrorCategory.unknown);
      });
    });

    group('getUserFriendlyMessage', () {
      test('should return user-friendly message for network errors', () {
        expect(ErrorHandler.getUserFriendlyMessage(ErrorCategory.network),
            'Please check your internet connection and try again.');
      });

      test('should return user-friendly message for server errors', () {
        expect(ErrorHandler.getUserFriendlyMessage(ErrorCategory.server),
            'There was a problem with our servers. Please try again later.');
      });

      test('should return user-friendly message for authentication errors', () {
        expect(
            ErrorHandler.getUserFriendlyMessage(ErrorCategory.authentication),
            'Your session has expired. Please sign in again to continue.');
      });

      test('should return user-friendly message for validation errors', () {
        expect(ErrorHandler.getUserFriendlyMessage(ErrorCategory.validation),
            'Some information you entered is not valid. Please check and try again.');
      });

      test('should return user-friendly message for permission errors', () {
        expect(ErrorHandler.getUserFriendlyMessage(ErrorCategory.permission),
            'You don\'t have permission to perform this action.');
      });

      test('should return user-friendly message for timeout errors', () {
        expect(ErrorHandler.getUserFriendlyMessage(ErrorCategory.timeout),
            'The operation is taking too long. Please try again later.');
      });

      test('should return user-friendly message for format errors', () {
        expect(ErrorHandler.getUserFriendlyMessage(ErrorCategory.format),
            'There was a problem processing the data. Please try again.');
      });

      test('should return user-friendly message for unknown errors', () {
        expect(ErrorHandler.getUserFriendlyMessage(ErrorCategory.unknown),
            'An unexpected error occurred. Please try again later.');
      });
    });
  });
}
