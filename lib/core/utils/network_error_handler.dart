import 'package:dio/dio.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';

/// Utility class to handle network errors consistently across the app
class NetworkErrorHandler {
  /// Handle Dio exceptions and convert them to standardized DataException
  static DataException handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return DataException(
          message: 'Connection timeout',
          debugMessage: 'Request took too long to complete',
          serverCode: 'TIMEOUT',
        );
      case DioExceptionType.sendTimeout:
        return DataException(
          message: 'Send timeout',
          debugMessage: 'Request took too long to send data',
          serverCode: 'TIMEOUT',
        );
      case DioExceptionType.receiveTimeout:
        return DataException(
          message: 'Receive timeout',
          debugMessage: 'Request took too long to receive data',
          serverCode: 'TIMEOUT',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        if (statusCode == 401) {
          return DataException(
            message: 'Unauthorized access',
            debugMessage: 'API key may be invalid or expired',
            serverCode: statusCode.toString(),
            extraJson: responseData,
          );
        } else if (statusCode == 404) {
          return DataException(
            message: 'Resource not found',
            debugMessage: 'The requested resource could not be found',
            serverCode: statusCode.toString(),
            extraJson: responseData,
          );
        } else if (statusCode == 429) {
          return DataException(
            message: 'Too many requests',
            debugMessage: 'Rate limit exceeded for API calls',
            serverCode: statusCode.toString(),
            extraJson: responseData,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return DataException(
            message: 'Service unavailable',
            debugMessage: 'Server error occurred: $statusCode',
            serverCode: statusCode.toString(),
            extraJson: responseData,
          );
        }
        return DataException(
          message: 'Service error',
          debugMessage:
              'Status: ${statusCode ?? "unknown"}, Response: $responseData',
          serverCode: statusCode?.toString(),
          extraJson: responseData,
        );
      case DioExceptionType.cancel:
        return DataException(
          message: 'Request cancelled',
          debugMessage: 'The request was cancelled',
          serverCode: 'CANCELLED',
        );
      case DioExceptionType.connectionError:
        return DataException(
          message: 'No internet connection',
          debugMessage: 'Please check your network connection',
          serverCode: 'CONNECTION_ERROR',
        );
      default:
        return DataException(
          message: 'Network error',
          debugMessage: e.toString(),
          serverCode: 'UNKNOWN',
        );
    }
  }

  /// Create a DataException from HTTP response
  static DataException createHttpException(int statusCode, dynamic responseData,
      {String? customMessage}) {
    final message = customMessage ?? 'Request failed';

    return DataException(
      message: message,
      serverCode: statusCode.toString(),
      debugMessage: 'Status code: $statusCode, Response: $responseData',
      extraJson: responseData,
    );
  }

  /// Create a generic exception
  static DataException createGenericException(dynamic error) {
    return DataException(
      message: 'Unexpected error occurred',
      debugMessage: error.toString(),
      serverCode: 'UNKNOWN',
    );
  }
}
