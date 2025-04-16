import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app_assignment/data/services/weather_service.dart';
import 'package:weather_app_assignment/data/models/weather_forecast.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/data/api_client.dart';
import '../../mocks/mock_generators.mocks.dart';

void main() {
  late WeatherService weatherService;
  late MockApiClient mockApiClient;

  const testApiKey = 'test_weather_api_key';
  const testLat = 37.7749;
  const testLon = -122.4194;
  const testUnits = 'metric';

  setUp(() {
    mockApiClient = MockApiClient();
    weatherService = WeatherService(
      apiKey: testApiKey,
      client: mockApiClient,
    );
  });

  group('WeatherService', () {
    test('getFourDaysForecast should return forecast data on success',
        () async {
      // Arrange
      final mockResponse = Response(
        data: {
          'lat': testLat,
          'lon': testLon,
          'timezone': 'America/New_York',
          'timezone_offset': -14400,
          'daily': [
            {
              'dt': 1600000000,
              'sunrise': 1599900000,
              'sunset': 1599940000,
              'temp': {
                'day': 25.5,
                'min': 20.1,
                'max': 28.3,
                'night': 22.2,
                'eve': 24.8,
                'morn': 21.5
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
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/onecall'),
      );

      when(mockApiClient.get(
        argThat(contains('onecall')),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await weatherService.getFourDaysForecast(
        lat: testLat,
        lon: testLon,
        units: testUnits,
      );

      // Assert
      verify(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).called(1);

      expect(result.isRight(), true);
      result.fold(
        (error) => fail('Should not return error'),
        (forecasts) {
          expect(forecasts.isNotEmpty, true);
          expect(forecasts[0].dt, 1600000000);
          expect(forecasts[0].temp.day, 25.5);
          expect(forecasts[0].temp.min, 20.1);
          expect(forecasts[0].weather.length, 1);
          expect(forecasts[0].weather[0].id, 800);
          expect(forecasts[0].weather[0].main, 'Clear');
        },
      );
    });

    test('getFourDaysForecast should return DataException on error', () async {
      // Arrange
      when(mockApiClient.get(
        argThat(contains('onecall')),
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/onecall'),
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 401,
          data: {'message': 'Unauthorized access'},
          requestOptions: RequestOptions(path: '/onecall'),
        ),
      ));

      // Act
      final result = await weatherService.getFourDaysForecast(
        lat: testLat,
        lon: testLon,
        units: testUnits,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<DataException>());
          expect(error.message, equals('Unauthorized access'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('getFourDaysForecast should handle network errors', () async {
      // Arrange
      when(mockApiClient.get(
        argThat(contains('onecall')),
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/onecall'),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timeout',
      ));

      // Act
      final result = await weatherService.getFourDaysForecast(
        lat: testLat,
        lon: testLon,
        units: testUnits,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<DataException>());
          expect(error.message, equals('Connection timeout'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('getFourDaysForecast should handle unexpected format', () async {
      // Arrange
      final mockResponse = Response(
        data: {'error': 'Unexpected error occurred'},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/onecall'),
      );

      when(mockApiClient.get(
        argThat(contains('onecall')),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await weatherService.getFourDaysForecast(
        lat: testLat,
        lon: testLon,
        units: testUnits,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<DataException>());
          expect(error.message, equals('Unexpected error occurred'));
        },
        (_) => fail('Should not return success'),
      );
    });
  });
}
