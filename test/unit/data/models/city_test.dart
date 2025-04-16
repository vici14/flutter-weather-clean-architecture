import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/data/models/city.dart';

void main() {
  group('City Model Tests', () {
    test('should properly parse from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'name': 'New York',
        'state_id': 43,
        'state_code': 'NY',
        'country_id': 101,
        'country_code': 'US',
        'latitude': '40.71427',
        'longitude': '-74.00597'
      };

      // Act
      final result = City.fromJson(jsonMap);

      // Assert
      expect(result.id, 1);
      expect(result.name, 'New York');
      expect(result.state_id, 43);
      expect(result.state_code, 'NY');
      expect(result.country_id, 101);
      expect(result.country_code, 'US');
      expect(result.latitude, '40.71427');
      expect(result.longitude, '-74.00597');
    });

    test('should serialize to JSON properly', () {
      // Arrange
      final city = City(
          id: 1,
          name: 'New York',
          state_id: 43,
          state_code: 'NY',
          country_id: 101,
          country_code: 'US',
          latitude: '40.71427',
          longitude: '-74.00597');

      // Act
      final jsonMap = city.toJson();

      // Assert
      expect(jsonMap['id'], 1);
      expect(jsonMap['name'], 'New York');
      expect(jsonMap['state_id'], 43);
      expect(jsonMap['state_code'], 'NY');
      expect(jsonMap['country_id'], 101);
      expect(jsonMap['country_code'], 'US');
      expect(jsonMap['latitude'], '40.71427');
      expect(jsonMap['longitude'], '-74.00597');
    });

    test('should handle null optional fields', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'name': 'New York',
        'state_id': 43,
        'state_code': 'NY',
        'country_id': 101,
        'country_code': 'US'
      };

      // Act
      final result = City.fromJson(jsonMap);

      // Assert
      expect(result.id, 1);
      expect(result.name, 'New York');
      expect(result.state_id, 43);
      expect(result.state_code, 'NY');
      expect(result.country_id, 101);
      expect(result.country_code, 'US');
      expect(result.latitude, null);
      expect(result.longitude, null);
    });
  });
}
