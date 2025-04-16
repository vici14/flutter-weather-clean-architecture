import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/data/models/weather_forecast.dart';

void main() {
  group('Weather Models Tests', () {
    group('CurrentWeather', () {
      test('should properly convert from JSON', () {
        // Arrange
        final Map<String, dynamic> json = {
          'dt': 1627815600,
          'sunrise': 1627789394,
          'sunset': 1627840917,
          'temp': 25.7,
          'feels_like': 26.1,
          'humidity': 65,
          'weather': [
            {
              'id': 800,
              'main': 'Clear',
              'description': 'clear sky',
              'icon': '01d'
            }
          ]
        };

        // Act
        final result = CurrentWeather.fromJson(json);

        // Assert
        expect(result.dt, 1627815600);
        expect(result.sunrise, 1627789394);
        expect(result.sunset, 1627840917);
        expect(result.temp, 25.7);
        expect(result.feelsLike, 26.1);
        expect(result.humidity, 65);
        expect(result.weather.length, 1);
        expect(result.weather[0].id, 800);
        expect(result.weather[0].main, 'Clear');
      });

      test('should properly convert to JSON', () {
        // Arrange
        final currentWeather = CurrentWeather(
          dt: 1627815600,
          sunrise: 1627789394,
          sunset: 1627840917,
          temp: 25.7,
          feelsLike: 26.1,
          humidity: 65,
          weather: [
            const WeatherCondition(
              id: 800,
              main: 'Clear',
              description: 'clear sky',
              icon: '01d',
            ),
          ],
        );

        // Act
        final json = currentWeather.toJson();

        // Assert
        expect(json['dt'], 1627815600);
        expect(json['sunrise'], 1627789394);
        expect(json['sunset'], 1627840917);
        expect(json['temp'], 25.7);
        expect(json['feels_like'], 26.1);
        expect(json['humidity'], 65);
        expect(json['weather'], isA<List>());
        expect(json['weather'].length, 1);

        // Check weather condition fields directly
        final weatherJson = json['weather'][0];
        expect(weatherJson['id'], 800);
        expect(weatherJson['main'], 'Clear');
        expect(weatherJson['description'], 'clear sky');
        expect(weatherJson['icon'], '01d');
      });
    });

    group('TempRange', () {
      test('should compute avgTemp correctly', () {
        // Arrange
        const tempRange = TempRange(
          day: 25.0,
          min: 18.0,
          max: 28.0,
          night: 20.0,
          eve: 24.0,
          morn: 19.0,
        );

        // Assert
        expect(tempRange.avgTemp, 23); // (18 + 28) / 2 = 23
      });

      test('should properly convert from JSON', () {
        // Arrange
        final Map<String, dynamic> json = {
          'day': 25.0,
          'min': 18.0,
          'max': 28.0,
          'night': 20.0,
          'eve': 24.0,
          'morn': 19.0,
        };

        // Act
        final result = TempRange.fromJson(json);

        // Assert
        expect(result.day, 25.0);
        expect(result.min, 18.0);
        expect(result.max, 28.0);
        expect(result.night, 20.0);
        expect(result.eve, 24.0);
        expect(result.morn, 19.0);
      });

      test('should properly convert to JSON', () {
        // Arrange
        const tempRange = TempRange(
          day: 25.0,
          min: 18.0,
          max: 28.0,
          night: 20.0,
          eve: 24.0,
          morn: 19.0,
        );

        // Act
        final json = tempRange.toJson();

        // Assert
        expect(json['day'], 25.0);
        expect(json['min'], 18.0);
        expect(json['max'], 28.0);
        expect(json['night'], 20.0);
        expect(json['eve'], 24.0);
        expect(json['morn'], 19.0);
      });
    });

    group('FeelsLike', () {
      test('should properly convert from JSON', () {
        // Arrange
        final Map<String, dynamic> json = {
          'day': 26.0,
          'night': 21.0,
          'eve': 25.0,
          'morn': 20.0,
        };

        // Act
        final result = FeelsLike.fromJson(json);

        // Assert
        expect(result.day, 26.0);
        expect(result.night, 21.0);
        expect(result.eve, 25.0);
        expect(result.morn, 20.0);
      });

      test('should properly convert to JSON', () {
        // Arrange
        const feelsLike = FeelsLike(
          day: 26.0,
          night: 21.0,
          eve: 25.0,
          morn: 20.0,
        );

        // Act
        final json = feelsLike.toJson();

        // Assert
        expect(json['day'], 26.0);
        expect(json['night'], 21.0);
        expect(json['eve'], 25.0);
        expect(json['morn'], 20.0);
      });
    });

    group('WeatherCondition', () {
      test('should properly convert from JSON', () {
        // Arrange
        final Map<String, dynamic> json = {
          'id': 800,
          'main': 'Clear',
          'description': 'clear sky',
          'icon': '01d',
        };

        // Act
        final result = WeatherCondition.fromJson(json);

        // Assert
        expect(result.id, 800);
        expect(result.main, 'Clear');
        expect(result.description, 'clear sky');
        expect(result.icon, '01d');
      });

      test('should properly convert to JSON', () {
        // Arrange
        const condition = WeatherCondition(
          id: 800,
          main: 'Clear',
          description: 'clear sky',
          icon: '01d',
        );

        // Act
        final json = condition.toJson();

        // Assert
        expect(json['id'], 800);
        expect(json['main'], 'Clear');
        expect(json['description'], 'clear sky');
        expect(json['icon'], '01d');
      });
    });
  });
}
