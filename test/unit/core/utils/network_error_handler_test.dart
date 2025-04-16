import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/core/utils/network_error_handler.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';

void main() {
  group('NetworkErrorHandler', () {
    test('handleDioException - connectionTimeout', () {
      final dioException = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );

      final result = NetworkErrorHandler.handleDioException(dioException);

      expect(result, isA<DataException>());
      expect(result.message, 'Connection timeout');
      expect(result.serverCode, 'TIMEOUT');
    });

    test('handleDioException - sendTimeout', () {
      final dioException = DioException(
        type: DioExceptionType.sendTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );

      final result = NetworkErrorHandler.handleDioException(dioException);

      expect(result, isA<DataException>());
      expect(result.message, 'Send timeout');
      expect(result.serverCode, 'TIMEOUT');
    });

    test('handleDioException - receiveTimeout', () {
      final dioException = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );

      final result = NetworkErrorHandler.handleDioException(dioException);

      expect(result, isA<DataException>());
      expect(result.message, 'Receive timeout');
      expect(result.serverCode, 'TIMEOUT');
    });

    test('handleDioException - badResponse 401', () {
      final dioException = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
          data: {'error': 'Unauthorized'},
        ),
      );

      final result = NetworkErrorHandler.handleDioException(dioException);

      expect(result, isA<DataException>());
      expect(result.message, 'Unauthorized access');
      expect(result.serverCode, '401');
      expect(result.extraJson, {'error': 'Unauthorized'});
    });

    test('handleDioException - badResponse 404', () {
      final dioException = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: '/test'),
          data: {'error': 'Not found'},
        ),
      );

      final result = NetworkErrorHandler.handleDioException(dioException);

      expect(result, isA<DataException>());
      expect(result.message, 'Resource not found');
      expect(result.serverCode, '404');
      expect(result.extraJson, {'error': 'Not found'});
    });

    test('handleDioException - badResponse 429', () {
      final dioException = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 429,
          requestOptions: RequestOptions(path: '/test'),
          data: {'error': 'Rate limit exceeded'},
        ),
      );

      final result = NetworkErrorHandler.handleDioException(dioException);

      expect(result, isA<DataException>());
      expect(result.message, 'Too many requests');
      expect(result.serverCode, '429');
      expect(result.extraJson, {'error': 'Rate limit exceeded'});
    });

    test('handleDioException - badResponse 500', () {
      final dioException = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/test'),
          data: {'error': 'Server error'},
        ),
      );

      final result = NetworkErrorHandler.handleDioException(dioException);

      expect(result, isA<DataException>());
      expect(result.message, 'Service unavailable');
      expect(result.serverCode, '500');
      expect(result.extraJson, {'error': 'Server error'});
    });

    test('handleDioException - badResponse other code', () {
      final dioException = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 418, // I'm a teapot
          requestOptions: RequestOptions(path: '/test'),
          data: {'error': 'I am a teapot'},
        ),
      );

      final result = NetworkErrorHandler.handleDioException(dioException);

      expect(result, isA<DataException>());
      expect(result.message, 'Service error');
      expect(result.serverCode, '418');
      expect(result.extraJson, {'error': 'I am a teapot'});
    });

    test('handleDioException - cancel', () {
      final dioException = DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(path: '/test'),
      );

      final result = NetworkErrorHandler.handleDioException(dioException);

      expect(result, isA<DataException>());
      expect(result.message, 'Request cancelled');
      expect(result.serverCode, 'CANCELLED');
    });

    test('handleDioException - connectionError', () {
      final dioException = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/test'),
      );

      final result = NetworkErrorHandler.handleDioException(dioException);

      expect(result, isA<DataException>());
      expect(result.message, 'No internet connection');
      expect(result.serverCode, 'CONNECTION_ERROR');
    });

    test('handleDioException - default', () {
      final dioException = DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: '/test'),
        error: 'Unknown error',
      );

      final result = NetworkErrorHandler.handleDioException(dioException);

      expect(result, isA<DataException>());
      expect(result.message, 'Network error');
      expect(result.serverCode, 'UNKNOWN');
    });

    test('createHttpException - with default message', () {
      final responseData = {'error': 'Test error'};

      final result = NetworkErrorHandler.createHttpException(400, responseData);

      expect(result, isA<DataException>());
      expect(result.message, 'Request failed');
      expect(result.serverCode, '400');
      expect(result.extraJson, responseData);
    });

    test('createHttpException - with custom message', () {
      final responseData = {'error': 'Test error'};
      final customMessage = 'Custom error message';

      final result = NetworkErrorHandler.createHttpException(400, responseData,
          customMessage: customMessage);

      expect(result, isA<DataException>());
      expect(result.message, customMessage);
      expect(result.serverCode, '400');
      expect(result.extraJson, responseData);
    });

    test('createGenericException', () {
      final error = Exception('Test exception');

      final result = NetworkErrorHandler.createGenericException(error);

      expect(result, isA<DataException>());
      expect(result.message, 'Unexpected error occurred');
      expect(result.serverCode, 'UNKNOWN');
      expect(result.debugMessage, 'Exception: Test exception');
    });
  });
}
