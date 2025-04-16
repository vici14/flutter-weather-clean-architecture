import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/data/exception/BaseApiErrorResponse.dart';

void main() {
  group('BaseApiErrorResponse', () {
    test('should create a BaseApiErrorResponse with null properties', () {
      final errorResponse = BaseApiErrorResponse();

      expect(errorResponse.code, isNull);
      expect(errorResponse.message, isNull);
      expect(errorResponse.data, isNull);
    });

    test('toJson serializes BaseApiErrorResponse correctly', () {
      final errorResponse = BaseApiErrorResponse()
        ..code = 'AUTH_ERROR'
        ..message = 'Authentication failed'
        ..data = {'userId': 'invalid'};

      final json = errorResponse.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['code'], 'AUTH_ERROR');
      expect(json['message'], 'Authentication failed');
      expect(json['data'], {'userId': 'invalid'});
    });

    test('fromJsonFactory creates BaseApiErrorResponse from JSON', () {
      final json = {
        'code': 'VALIDATION_ERROR',
        'message': 'Validation failed',
        'data': {
          'fields': ['email', 'password']
        }
      };

      final errorResponse = BaseApiErrorResponse.fromJsonFactory(json);

      expect(errorResponse, isA<BaseApiErrorResponse>());
      expect(errorResponse.code, 'VALIDATION_ERROR');
      expect(errorResponse.message, 'Validation failed');
      expect(errorResponse.data, {
        'fields': ['email', 'password']
      });
    });

    test('fromJsonFactory handles null values', () {
      final json = {'code': null, 'message': null, 'data': null};

      final errorResponse = BaseApiErrorResponse.fromJsonFactory(json);

      expect(errorResponse, isA<BaseApiErrorResponse>());
      expect(errorResponse.code, isNull);
      expect(errorResponse.message, isNull);
      expect(errorResponse.data, isNull);
    });

    test('fromJsonFactory handles partial JSON', () {
      final json = {
        'code': 'TIMEOUT',
      };

      final errorResponse = BaseApiErrorResponse.fromJsonFactory(json);

      expect(errorResponse, isA<BaseApiErrorResponse>());
      expect(errorResponse.code, 'TIMEOUT');
      expect(errorResponse.message, isNull);
      expect(errorResponse.data, isNull);
    });
  });
}
