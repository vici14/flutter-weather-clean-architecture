import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/core/error/AppError.dart';

enum ErrorCategory {
  network,
  server,
  authentication,
  validation,
  permission,
  timeout,
  format,
  unknown
}

class ErrorHandler {
  /// Convert any exception to AppError
  static AppError handleError(dynamic error, {String? context}) {
    final AppError appError = _mapErrorToAppError(error, context);

    // Log the error (you can implement your own logging mechanism)
    _logError(appError, error);

    return appError;
  }

  /// Maps different error types to appropriate AppError
  static AppError _mapErrorToAppError(dynamic error, String? context) {
    // Network errors
    if (error is SocketException) {
      return AppError(
        title: 'Network Error',
        message: 'Please check your internet connection',
        errorCode: 'NETWORK_ERROR',
        isNetworkException: true,
      );
    }
    // Timeout errors
    else if (error is TimeoutException) {
      return AppError(
        title: 'Request Timeout',
        message: 'The server took too long to respond',
        errorCode: 'TIMEOUT_ERROR',
        isNetworkException: true,
      );
    }
    // Format errors
    else if (error is FormatException) {
      return AppError(
        title: 'Format Error',
        message: 'Unable to process the data',
        errorCode: 'FORMAT_ERROR',
        debugMessage: error.message,
      );
    }
    // JSON parse errors
    else if (error is JsonUnsupportedObjectError || error is JsonCyclicError) {
      return AppError(
        title: 'Data Processing Error',
        message: 'Unable to process server response',
        errorCode: 'JSON_ERROR',
        debugMessage: error.toString(),
      );
    }
    // API errors
    else if (error is DataException) {
      return AppError.fromDataException(error);
    }
    // Platform/Native errors
    else if (error is PlatformException) {
      return AppError.fromPlatformException(error);
    }
    // HTTP status code errors
    else if (error is HttpException) {
      return AppError(
        title: 'Server Error',
        message: error.message,
        errorCode: 'HTTP_ERROR',
      );
    }
    // Permission errors
    else if (error.toString().toLowerCase().contains('permission') ||
        error.toString().toLowerCase().contains('access denied')) {
      return AppError(
        title: 'Permission Error',
        message: 'You don\'t have permission to perform this action',
        errorCode: 'PERMISSION_ERROR',
        debugMessage: error.toString(),
      );
    }
    // Authentication errors
    else if (error.toString().toLowerCase().contains('unauthorized') ||
        error.toString().toLowerCase().contains('unauthenticated') ||
        error.toString().toLowerCase().contains('auth') ||
        error.toString().toLowerCase().contains('token')) {
      return AppError(
        title: 'Authentication Error',
        message: 'Please sign in again to continue',
        errorCode: 'AUTH_ERROR',
        debugMessage: error.toString(),
      );
    }
    // Generic exceptions
    else if (error is Exception || error is Error) {
      String errorContext = context != null ? ' in $context' : '';
      return AppError(
        title: 'Error',
        message: 'An error occurred$errorContext',
        errorCode: 'GENERIC_ERROR',
        debugMessage: error.toString(),
      );
    }
    // Fallback for unknown errors
    else {
      return AppError(
        title: 'Unknown Error',
        message: error?.toString() ?? 'An unknown error occurred',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Get error category for analytics and reporting
  static ErrorCategory categorizeError(dynamic error) {
    if (error is SocketException ||
        error.toString().toLowerCase().contains('network') ||
        error.toString().toLowerCase().contains('connection')) {
      return ErrorCategory.network;
    } else if (error.toString().toLowerCase().contains('unauthorized') ||
        error.toString().toLowerCase().contains('unauthenticated') ||
        error.toString().toLowerCase().contains('auth') ||
        error.toString().toLowerCase().contains('token')) {
      return ErrorCategory.authentication;
    } else if (error.toString().toLowerCase().contains('permission') ||
        error.toString().toLowerCase().contains('access denied')) {
      return ErrorCategory.permission;
    } else if (error is TimeoutException ||
        error.toString().toLowerCase().contains('timeout')) {
      return ErrorCategory.timeout;
    } else if (error is FormatException ||
        error is JsonUnsupportedObjectError ||
        error is JsonCyclicError) {
      return ErrorCategory.format;
    } else if (error is HttpException ||
        error is DataException ||
        error.toString().toLowerCase().contains('server')) {
      return ErrorCategory.server;
    } else if (error.toString().toLowerCase().contains('invalid') ||
        error.toString().toLowerCase().contains('validation')) {
      return ErrorCategory.validation;
    } else {
      return ErrorCategory.unknown;
    }
  }

  /// Log the error (can be connected to a logging service)
  static void _logError(AppError appError, dynamic originalError) {
    // Add your logging implementation here
    // For example, with Firebase Crashlytics or other logging service

    // This is a simple console log for now
    print('APP ERROR: ${appError.title} - ${appError.message}');
    print('DEBUG: ${appError.debugMessage}');
    print('ORIGINAL ERROR: $originalError');
  }

  /// Get user-friendly message based on error category
  static String getUserFriendlyMessage(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
        return 'Please check your internet connection and try again.';
      case ErrorCategory.server:
        return 'There was a problem with our servers. Please try again later.';
      case ErrorCategory.authentication:
        return 'Your session has expired. Please sign in again to continue.';
      case ErrorCategory.validation:
        return 'Some information you entered is not valid. Please check and try again.';
      case ErrorCategory.permission:
        return 'You don\'t have permission to perform this action.';
      case ErrorCategory.timeout:
        return 'The operation is taking too long. Please try again later.';
      case ErrorCategory.format:
        return 'There was a problem processing the data. Please try again.';
      case ErrorCategory.unknown:
      default:
        return 'An unexpected error occurred. Please try again later.';
    }
  }
}
