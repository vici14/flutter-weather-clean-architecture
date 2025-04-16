import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/data/models/weather_forecast.dart';

void main() {
  group('WeatherForecast Model Tests', () {
    test('should properly parse from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'lat': 40.7128,
        'lon': -74.0060,
        'timezone': 'America/New_York',
        'timezone_offset': -14400,
        'current': {
          'dt': 1627246800,
          'sunrise': 1627207155,
          'sunset': 1627260014,
          'temp': 28.5,
          'feels_like': 30.2,
          'humidity': 65,
          'weather': [
            {
              'id': 800,
              'main': 'Clear',
              'description': 'clear sky',
              'icon': '01d'
            }
          ]
        },
        'daily': [
          {
            'dt': 1627232400,
            'sunrise': 1627207155,
            'sunset': 1627260014,
            'temp': {
              'day': 28.5,
              'min': 22.3,
              'max': 30.1,
              'night': 23.5,
              'eve': 27.8,
              'morn': 24.2
            },
            'feels_like': {
              'day': 30.2,
              'night': 23.8,
              'eve': 28.9,
              'morn': 24.5
            },
            'weather': [
              {
                'id': 800,
                'main': 'Clear',
                'description': 'clear sky',
                'icon': '01d'
              }
            ]
          }
        ]
      };

      // Act
      final result = WeatherForecast.fromJson(jsonMap);

      // Assert
      expect(result.lat, 40.7128);
      expect(result.lon, -74.0060);
      expect(result.timezone, 'America/New_York');
      expect(result.timezoneOffset, -14400);

      // Current weather assertions
      expect(result.current, isNotNull);
      expect(result.current!.temp, 28.5);
      expect(result.current!.feelsLike, 30.2);
      expect(result.current!.humidity, 65);
      expect(result.current!.weather.length, 1);
      expect(result.current!.weather.first.main, 'Clear');

      // Daily forecast assertions
      expect(result.daily.length, 1);
      expect(result.daily.first.dt, 1627232400);
      expect(result.daily.first.temp.day, 28.5);
      expect(result.daily.first.temp.min, 22.3);
      expect(result.daily.first.temp.max, 30.1);
    });

    test('should serialize to JSON properly', () {
      // Arrange
      final weatherCondition = WeatherCondition(
          id: 800, main: 'Clear', description: 'clear sky', icon: '01d');

      final tempRange = TempRange(
          day: 28.5, min: 22.3, max: 30.1, night: 23.5, eve: 27.8, morn: 24.2);

      final feelsLike =
          FeelsLike(day: 30.2, night: 23.8, eve: 28.9, morn: 24.5);

      final currentWeather = CurrentWeather(
          dt: 1627246800,
          sunrise: 1627207155,
          sunset: 1627260014,
          temp: 28.5,
          feelsLike: 30.2,
          humidity: 65,
          weather: [weatherCondition]);

      final dailyForecast = DailyForecast(
          dt: 1627232400,
          sunrise: 1627207155,
          sunset: 1627260014,
          temp: tempRange,
          feelsLike: feelsLike,
          weather: [weatherCondition]);

      final weatherForecast = WeatherForecast(
          lat: 40.7128,
          lon: -74.0060,
          timezone: 'America/New_York',
          timezoneOffset: -14400,
          current: currentWeather,
          daily: [dailyForecast]);

      // Act
      final jsonMap = weatherForecast.toJson();

      // Assert
      expect(jsonMap, isA<Map<String, dynamic>>());
      expect(jsonMap['lat'], 40.7128);
      expect(jsonMap['lon'], -74.0060);
      expect(jsonMap['timezone'], 'America/New_York');
      expect(jsonMap['timezone_offset'], -14400);

      // Check that the current weather is included
      expect(jsonMap['current'], isA<Map<String, dynamic>>());

      // Check that daily forecasts are included
      expect(jsonMap['daily'], isA<List>());
      expect(jsonMap['daily'].length, 1);
    });

    test('TempRange.avgTemp should calculate correctly', () {
      // Arrange
      final tempRange = TempRange(
          day: 28.5, min: 20.0, max: 30.0, night: 23.5, eve: 27.8, morn: 24.2);

      // Act & Assert
      expect(tempRange.avgTemp, 25); // (20 + 30) / 2 = 25
    });

    group('TempRange', () {
      test('constructor sets values correctly', () {
        const tempRange = TempRange(
          day: 25.5,
          min: 20.0,
          max: 30.0,
          night: 18.5,
          eve: 22.0,
          morn: 21.0,
        );

        expect(tempRange.day, 25.5);
        expect(tempRange.min, 20.0);
        expect(tempRange.max, 30.0);
        expect(tempRange.night, 18.5);
        expect(tempRange.eve, 22.0);
        expect(tempRange.morn, 21.0);
      });

      test('avgTemp calculates correctly - scenario 1', () {
        const tempRange = TempRange(
          day: 25.5,
          min: 20.0,
          max: 30.0,
          night: 18.5,
          eve: 22.0,
          morn: 21.0,
        );

        // avgTemp should be ((min + max) / 2).round()
        // (20.0 + 30.0) / 2 = 25.0, rounded to 25
        expect(tempRange.avgTemp, 25);
      });

      test('avgTemp calculates correctly - scenario 2', () {
        const tempRange = TempRange(
          day: 25.5,
          min: 19.3,
          max: 31.8,
          night: 18.5,
          eve: 22.0,
          morn: 21.0,
        );

        // avgTemp should be ((min + max) / 2).round()
        // (19.3 + 31.8) / 2 = 25.55, rounded to 26
        expect(tempRange.avgTemp, 26);
      });

      test('avgTemp handles negative temperatures', () {
        const tempRange = TempRange(
          day: -5.0,
          min: -10.0,
          max: 0.0,
          night: -12.0,
          eve: -7.0,
          morn: -8.0,
        );

        // avgTemp should be ((-10.0 + 0.0) / 2).round()
        // = -5.0, rounded to -5
        expect(tempRange.avgTemp, -5);
      });

      test('avgTemp handles when min and max are the same', () {
        const tempRange = TempRange(
          day: 20.0,
          min: 20.0,
          max: 20.0,
          night: 20.0,
          eve: 20.0,
          morn: 20.0,
        );

        // avgTemp should be ((20.0 + 20.0) / 2).round()
        // = 20.0, rounded to 20
        expect(tempRange.avgTemp, 20);
      });
    });

    const jsonString = '''
    {
      "lat": 40.7128,
      "lon": -74.006,
      "timezone": "America/New_York",
      "timezone_offset": -14400,
      "daily": [
        {
          "dt": 1600000000,
          "sunrise": 1599900000,
          "sunset": 1599940000,
          "temp": {
            "day": 25.5,
            "min": 20.1,
            "max": 28.3,
            "night": 22.2,
            "eve": 24.8,
            "morn": 21.5
          },
          "feels_like": {
            "day": 24.5,
            "night": 21.2,
            "eve": 23.8,
            "morn": 20.5
          },
          "pressure": 1015,
          "humidity": 65,
          "dew_point": 18.2,
          "wind_speed": 4.5,
          "wind_deg": 180,
          "weather": [
            {
              "id": 800,
              "main": "Clear",
              "description": "clear sky",
              "icon": "01d"
            }
          ],
          "clouds": 5,
          "pop": 0.2,
          "uvi": 6.5
        }
      ]
    }
    ''';

    test('fromJson should correctly parse JSON', () {
      // Act
      final weatherForecast = WeatherForecast.fromJson(json.decode(jsonString));

      // Assert
      expect(weatherForecast.lat, 40.7128);
      expect(weatherForecast.lon, -74.006);
      expect(weatherForecast.timezone, 'America/New_York');
      expect(weatherForecast.timezoneOffset, -14400);
      expect(weatherForecast.daily.length, 1);

      final dailyForecast = weatherForecast.daily.first;
      expect(dailyForecast.dt, 1600000000);
      expect(dailyForecast.sunrise, 1599900000);
      expect(dailyForecast.sunset, 1599940000);
      expect(dailyForecast.temp.day, 25.5);
      expect(dailyForecast.temp.min, 20.1);
      expect(dailyForecast.temp.max, 28.3);
      expect(dailyForecast.temp.night, 22.2);
      expect(dailyForecast.temp.eve, 24.8);
      expect(dailyForecast.temp.morn, 21.5);

      expect(dailyForecast.feelsLike?.day, 24.5);
      expect(dailyForecast.feelsLike?.night, 21.2);
      expect(dailyForecast.feelsLike?.eve, 23.8);
      expect(dailyForecast.feelsLike?.morn, 20.5);

      expect(dailyForecast.pressure, 1015);
      expect(dailyForecast.humidity, 65);
      expect(dailyForecast.dewPoint, 18.2);
      expect(dailyForecast.windSpeed, 4.5);
      expect(dailyForecast.windDeg, 180);

      expect(dailyForecast.weather.length, 1);
      expect(dailyForecast.weather.first.id, 800);
      expect(dailyForecast.weather.first.main, 'Clear');
      expect(dailyForecast.weather.first.description, 'clear sky');
      expect(dailyForecast.weather.first.icon, '01d');

      expect(dailyForecast.clouds, 5);
      expect(dailyForecast.pop, 0.2);
      expect(dailyForecast.uvi, 6.5);
    });

    test('toJson should correctly serialize to JSON', () {
      // Create a simple weather forecast
      final weatherForecast = WeatherForecast(
        lat: 40.7128,
        lon: -74.0060,
        timezone: 'America/New_York',
        timezoneOffset: -14400,
        current: CurrentWeather(
          dt: 1627246800,
          sunrise: 1627207155,
          sunset: 1627260014,
          temp: 28.5,
          feelsLike: 30.2,
          humidity: 65,
          weather: [
            WeatherCondition(
                id: 800, main: 'Clear', description: 'clear sky', icon: '01d')
          ],
        ),
        daily: [
          DailyForecast(
            dt: 1627232400,
            sunrise: 1627207155,
            sunset: 1627260014,
            temp: TempRange(
                day: 28.5,
                min: 22.3,
                max: 30.1,
                night: 23.5,
                eve: 27.8,
                morn: 24.2),
            feelsLike: FeelsLike(day: 30.2, night: 23.8, eve: 28.9, morn: 24.5),
            weather: [
              WeatherCondition(
                  id: 800, main: 'Clear', description: 'clear sky', icon: '01d')
            ],
          ),
        ],
      );

      // Convert to JSON
      final json = weatherForecast.toJson();

      // Basic checks
      expect(json, isA<Map<String, dynamic>>());
      expect(json.containsKey('lat'), true);
      expect(json.containsKey('lon'), true);
      expect(json.containsKey('timezone'), true);
      expect(json.containsKey('timezone_offset'), true);
      expect(json.containsKey('current'), true);
      expect(json.containsKey('daily'), true);

      // Ensure deep structures are there
      expect(json['current'], isA<Map<String, dynamic>>());
      expect(json['daily'], isA<List>());
      expect(json['daily'].length, 1);
    });

    test('copyWith should create a copy with modified values', () {
      // Arrange
      final original = WeatherForecast.fromJson(json.decode(jsonString));

      // Act
      final copied = original.copyWith(
        lat: 42.0,
        lon: -71.0,
        timezone: 'America/Chicago',
      );

      // Assert
      expect(copied.lat, 42.0);
      expect(copied.lon, -71.0);
      expect(copied.timezone, 'America/Chicago');
      expect(copied.timezoneOffset, original.timezoneOffset);
      expect(copied.daily, original.daily);

      // Original should remain unchanged
      expect(original.lat, 40.7128);
      expect(original.lon, -74.006);
      expect(original.timezone, 'America/New_York');
    });

    test('DailyForecast copyWith should create a copy with modified values',
        () {
      // Arrange
      final original =
          WeatherForecast.fromJson(json.decode(jsonString)).daily.first;

      // Act
      final copied = original.copyWith(
        dt: 1600100000,
        pressure: 1020,
        humidity: 70,
      );

      // Assert
      expect(copied.dt, 1600100000);
      expect(copied.pressure, 1020);
      expect(copied.humidity, 70);

      // Rest should be the same
      expect(copied.sunrise, original.sunrise);
      expect(copied.sunset, original.sunset);
      expect(copied.temp, original.temp);

      // Original should remain unchanged
      expect(original.dt, 1600000000);
      expect(original.pressure, 1015);
      expect(original.humidity, 65);
    });
  });
}
