import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/data/models/state.dart';

void main() {
  group('State Model Tests', () {
    test('should properly parse from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 43,
        'name': 'New York',
        'country_id': 101,
        'country_code': 'US',
        'iso2': 'NY',
        'type': 'state',
        'latitude': '43.00000000',
        'longitude': '-75.00000000'
      };

      // Act
      final result = State.fromJson(jsonMap);

      // Assert
      expect(result.id, 43);
      expect(result.name, 'New York');
      expect(result.country_id, 101);
      expect(result.country_code, 'US');
      expect(result.iso2, 'NY');
      expect(result.type, 'state');
      expect(result.latitude, '43.00000000');
      expect(result.longitude, '-75.00000000');
    });

    test('should serialize to JSON properly', () {
      // Arrange
      final state = State(
          id: 43,
          name: 'New York',
          country_id: 101,
          country_code: 'US',
          iso2: 'NY',
          type: 'state',
          latitude: '43.00000000',
          longitude: '-75.00000000');

      // Act
      final jsonMap = state.toJson();

      // Assert
      expect(jsonMap['id'], 43);
      expect(jsonMap['name'], 'New York');
      expect(jsonMap['country_id'], 101);
      expect(jsonMap['country_code'], 'US');
      expect(jsonMap['iso2'], 'NY');
      expect(jsonMap['type'], 'state');
      expect(jsonMap['latitude'], '43.00000000');
      expect(jsonMap['longitude'], '-75.00000000');
    });

    test('should handle null optional fields', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 43,
        'name': 'New York',
        'country_id': 101,
        'country_code': 'US',
        'iso2': 'NY',
        'type': 'state'
      };

      // Act
      final result = State.fromJson(jsonMap);

      // Assert
      expect(result.id, 43);
      expect(result.name, 'New York');
      expect(result.country_id, 101);
      expect(result.country_code, 'US');
      expect(result.iso2, 'NY');
      expect(result.type, 'state');
      expect(result.latitude, null);
      expect(result.longitude, null);
    });
  });
}
