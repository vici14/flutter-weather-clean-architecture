import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/core/models/location_data.dart';

void main() {
  group('LocationData', () {
    test('constructor sets values correctly', () {
      const locationData =
          LocationData(lat: '40.7128', long: '-74.0060', name: 'New York');

      expect(locationData.lat, '40.7128');
      expect(locationData.long, '-74.0060');
      expect(locationData.name, 'New York');
    });

    test('latitude getter parses string correctly', () {
      const locationData =
          LocationData(lat: '40.7128', long: '-74.0060', name: 'New York');

      expect(locationData.latitude, 40.7128);
    });

    test('longitude getter parses string correctly', () {
      const locationData =
          LocationData(lat: '40.7128', long: '-74.0060', name: 'New York');

      expect(locationData.longitude, -74.0060);
    });

    test('latitude getter returns 0 for invalid string', () {
      const locationData =
          LocationData(lat: 'invalid', long: '-74.0060', name: 'New York');

      expect(locationData.latitude, 0);
    });

    test('longitude getter returns 0 for invalid string', () {
      const locationData =
          LocationData(lat: '40.7128', long: 'invalid', name: 'New York');

      expect(locationData.longitude, 0);
    });
  });
}
