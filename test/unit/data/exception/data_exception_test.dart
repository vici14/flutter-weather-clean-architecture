import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';

void main() {
  group('DataException', () {
    test('should create DataException with correct properties', () {
      const message = 'Error message';
      const title = 'Error title';
      const debugMessage = 'Debug message';
      const serverCode = '500';
      final extraJson = {'details': 'Server error'};

      final exception = DataException(
        message: message,
        title: title,
        debugMessage: debugMessage,
        serverCode: serverCode,
        extraJson: extraJson,
      );

      expect(exception.message, message);
      expect(exception.title, title);
      expect(exception.debugMessage, debugMessage);
      expect(exception.serverCode, serverCode);
      expect(exception.extraJson, extraJson);
    });

    test('toString returns formatted string with all properties', () {
      final exception = DataException(
        message: 'Not found',
        title: 'Resource error',
        debugMessage: 'Item with ID 123 not found',
        serverCode: '404',
        extraJson: {'id': '123'},
      );

      final stringRepresentation = exception.toString();

      expect(stringRepresentation, contains('DataException'));
      expect(stringRepresentation, contains('statusCode: null'));
      expect(stringRepresentation, contains('serverCode: 404'));
      expect(stringRepresentation, contains('message: Not found'));
      expect(stringRepresentation, contains('title: Resource error'));
      expect(stringRepresentation,
          contains('debugMessage: Item with ID 123 not found'));
      expect(stringRepresentation, contains('extraJson: {id: 123}'));
    });

    test('toJson serializes DataException correctly', () {
      final exception = DataException(
        message: 'Validation error',
        title: 'Form error',
        debugMessage: 'Email is invalid',
        serverCode: '422',
        extraJson: {'field': 'email'},
      );

      final json = exception.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['message'], 'Validation error');
      expect(json['title'], 'Form error');
      expect(json['debugMessage'], 'Email is invalid');
      expect(json['serverCode'], '422');
      expect(json['extraJson'], {'field': 'email'});
    });

    test('fromJsonFactory creates DataException from JSON', () {
      final json = {
        'message': 'Server error',
        'title': 'Connection problem',
        'debugMessage': 'Database timeout',
        'serverCode': '503',
        'extraJson': {'retry': true},
      };

      final exception = DataException.fromJsonFactory(json);

      expect(exception, isA<DataException>());
      expect(exception.message, 'Server error');
      expect(exception.title, 'Connection problem');
      expect(exception.debugMessage, 'Database timeout');
      expect(exception.serverCode, '503');
      expect(exception.extraJson, {'retry': true});
    });
  });
}
