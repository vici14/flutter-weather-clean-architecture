import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:weather_app_assignment/data/services/weather_service.dart';
import 'package:weather_app_assignment/data/models/weather_forecast.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';

import 'api_client_mock.dart';

void main() {
  late MockApiClient mockApiClient;
  late WeatherService weatherService;
  const String testApiKey = 'test_weather_api_key';
  const double testLat = 37.7749;
  const double testLon = -122.4194;
  const String testUnits = 'metric';

  setUp(() {
    mockApiClient = MockApiClient();
    weatherService = WeatherService(
      apiKey: testApiKey,
      client: mockApiClient,
    );
  });

  group('getWeatherForecast', () {
    final mockWeatherResponse = {
      'lat': testLat,
      'lon': testLon,
      'timezone': 'America/Los_Angeles',
      'timezone_offset': -25200,
      'daily': [
        {
          'dt': 1617984000,
          'sunrise': 1617962100,
          'sunset': 1618009793,
          'temp': {
            'day': 15.23,
            'min': 10.54,
            'max': 16.02,
            'night': 10.54,
            'eve': 13.09,
            'morn': 11.32,
          },
          'feels_like': {
            'day': 14.53,
            'night': 9.79,
            'eve': 12.45,
            'morn': 10.32,
          },
          'pressure': 1018,
          'humidity': 71,
          'dew_point': 10.2,
          'wind_speed': 3.06,
          'wind_deg': 225,
          'weather': [
            {
              'id': 804,
              'main': 'Clouds',
              'description': 'overcast clouds',
              'icon': '04d',
            },
          ],
          'clouds': 90,
          'pop': 0.2,
          'uvi': 6.54,
        },
      ],
    };

    Map<String, dynamic> expectedQueryParams = {
      'lat': testLat,
      'lon': testLon,
      'units': testUnits,
      'exclude': 'current,minutely,hourly,alerts',
      'appid': testApiKey,
    };

    test('returns weather forecast when API call is successful', () async {
      // Arrange
      mockApiClient.onGet = (path, {queryParameters, headers}) {
        expect(path, equals('https://api.openweathermap.org/data/3.0/onecall'));
        expect(queryParameters, equals(expectedQueryParams));
        return mockWeatherResponse;
      };

      // Act
      final result = await weatherService.getWeatherForecast(
        lat: testLat,
        lon: testLon,
        units: testUnits,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return a failure'),
        (forecast) {
          expect(forecast.lat, equals(testLat));
          expect(forecast.lon, equals(testLon));
          expect(forecast.timezone, equals('America/Los_Angeles'));
          expect(forecast.timezoneOffset, equals(-25200));
          expect(forecast.daily.length, equals(1));
          expect(forecast.daily[0].temp.day, equals(15.23));
          expect(forecast.daily[0].temp.min, equals(10.54));
          expect(forecast.daily[0].weather[0].main, equals('Clouds'));
        },
      );
    });

    test('returns DataException when API returns error code', () async {
      // Arrange
      mockApiClient.statusCode = 401;
      mockApiClient.onGet = (path, {queryParameters, headers}) {
        return {'message': 'Invalid API key'};
      };

      // Act
      final result = await weatherService.getWeatherForecast(
        lat: testLat,
        lon: testLon,
        units: testUnits,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(
              exception.message, contains('Failed to load weather forecast'));
        },
        (forecast) => fail('Should not return forecast'),
      );
    });

    test('returns DataException when API call throws DioException', () async {
      // Arrange
      mockApiClient.throwDioError = true;
      mockApiClient.errorMessage = 'Connection timeout';
      mockApiClient.dioErrorType = DioExceptionType.connectionTimeout;

      // Act
      final result = await weatherService.getWeatherForecast(
        lat: testLat,
        lon: testLon,
        units: testUnits,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(exception.message, contains('Connection timeout'));
        },
        (forecast) => fail('Should not return forecast'),
      );
    });

    test('returns DataException when API call throws unexpected error',
        () async {
      // Arrange
      mockApiClient.throwGenericError = true;
      mockApiClient.errorMessage = 'Unexpected error';

      // Act
      final result = await weatherService.getWeatherForecast(
        lat: testLat,
        lon: testLon,
        units: testUnits,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error.message, 'Unexpected error occurred'),
        (_) => fail('Should return left with DataException'),
      );
    });
  });

  group('getFourDaysForecast', () {
    // Since getFourDaysForecast depends on getWeatherForecast, we can create a test
    // that verifies the proper delegation and result transformation
    final mockWeatherResponse = {
      'lat': testLat,
      'lon': testLon,
      'timezone': 'America/Los_Angeles',
      'timezone_offset': -25200,
      'daily': [
        {
          'dt': 1617984000,
          'sunrise': 1617962100,
          'sunset': 1618009793,
          'temp': {
            'day': 15.23,
            'min': 10.54,
            'max': 16.02,
            'night': 10.54,
            'eve': 13.09,
            'morn': 11.32,
          },
          'feels_like': {
            'day': 14.53,
            'night': 9.79,
            'eve': 12.45,
            'morn': 10.32,
          },
          'pressure': 1018,
          'humidity': 71,
          'dew_point': 10.2,
          'wind_speed': 3.06,
          'wind_deg': 225,
          'weather': [
            {
              'id': 804,
              'main': 'Clouds',
              'description': 'overcast clouds',
              'icon': '04d',
            },
          ],
          'clouds': 90,
          'pop': 0.2,
          'uvi': 6.54,
        },
        {
          'dt': 1618070400,
          'sunrise': 1618048380,
          'sunset': 1618096249,
          'temp': {
            'day': 16.78,
            'min': 11.65,
            'max': 17.25,
            'night': 11.65,
            'eve': 14.32,
            'morn': 12.45,
          },
          'feels_like': {
            'day': 15.98,
            'night': 10.85,
            'eve': 13.65,
            'morn': 11.45,
          },
          'pressure': 1020,
          'humidity': 68,
          'dew_point': 9.8,
          'wind_speed': 2.75,
          'wind_deg': 220,
          'weather': [
            {
              'id': 801,
              'main': 'Clouds',
              'description': 'few clouds',
              'icon': '02d',
            },
          ],
          'clouds': 20,
          'pop': 0.0,
          'uvi': 7.12,
        },
      ],
    };

    test('returns four days forecast when API call is successful', () async {
      // Arrange
      mockApiClient.onGet = (path, {queryParameters, headers}) {
        return mockWeatherResponse;
      };

      // Act
      final result = await weatherService.getFourDaysForecast(
        lat: testLat,
        lon: testLon,
        units: testUnits,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return a failure'),
        (forecasts) {
          expect(forecasts.length, equals(2));
          expect(forecasts[0].temp.day, equals(15.23));
          expect(forecasts[1].temp.day, equals(16.78));
        },
      );
    });

    test('returns DataException when API call fails', () async {
      // Arrange
      mockApiClient.statusCode = 401;
      mockApiClient.onGet = (path, {queryParameters, headers}) {
        return {'message': 'Invalid API key'};
      };

      // Act
      final result = await weatherService.getFourDaysForecast(
        lat: testLat,
        lon: testLon,
        units: testUnits,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(
              exception.message, contains('Failed to load weather forecast'));
        },
        (forecasts) => fail('Should not return forecasts'),
      );
    });
  });
}
