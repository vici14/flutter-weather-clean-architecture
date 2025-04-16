import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/data/models/weather_forecast.dart';
import 'package:weather_app_assignment/data/repositories/weather_repository.dart';
import 'package:weather_app_assignment/data/service_manager.dart';
import 'package:weather_app_assignment/data/services/weather_service.dart';

import '../../mocks/test_helpers.dart';

class MockServiceManager extends Mock implements ServiceManager {
  // No need to override the method as Mockito will handle it
}

class MockWeatherService extends Mock implements WeatherService {}

void main() {
  late WeatherRepository weatherRepository;
  late MockServiceManager mockServiceManager;
  late MockWeatherService mockWeatherService;

  setUp(() {
    mockServiceManager = MockServiceManager();
    mockWeatherService = MockWeatherService();
    when(mockServiceManager.weatherService).thenReturn(mockWeatherService);
    weatherRepository = WeatherRepository(mockServiceManager);
  });

  group('WeatherRepository', () {
    final mockForecasts = List.generate(
      5,
      (index) => DailyForecast(
        dt: 1234567890 + (index * 86400),
        temp: TempRange(
          day: 20 + index.toDouble(),
          min: 15 + index.toDouble(),
          max: 25 + index.toDouble(),
          night: 18 + index.toDouble(),
          eve: 22 + index.toDouble(),
          morn: 16 + index.toDouble(),
        ),
        weather: [
          WeatherCondition(
              id: 800, main: 'Clear', description: 'clear sky', icon: '01d')
        ],
        sunrise: 1234567890,
        sunset: 1234567890 + 43200,
      ),
    );

    group('getFourDaysForecast', () {
      test('returns forecast data when service call is successful', () async {
        // Arrange
        when(mockWeatherService.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        )).thenAnswer((_) async => Right(mockForecasts));

        // Act
        final result = await weatherRepository.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (error) => fail('Should not return error'),
          (forecasts) {
            expect(forecasts, equals(mockForecasts));
            expect(forecasts.length, equals(5));
          },
        );

        verify(mockWeatherService.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        )).called(1);
      });

      test('returns DataException when service call fails', () async {
        // Arrange
        when(mockWeatherService.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        )).thenAnswer(
            (_) async => Left(DataException(message: 'Service error')));

        // Act
        final result = await weatherRepository.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error, isA<DataException>());
            expect(error.message, equals('Service error'));
          },
          (forecasts) => fail('Should not return success'),
        );
      });

      test('returns DataException when service is null', () async {
        // Set up a custom expectation for this test
        mockServiceManager = MockServiceManager();
        // Return a null service which will be handled as null in the actual code
        when(mockServiceManager.weatherService)
            .thenAnswer((_) => throw StateError('Service not available'));

        // Create a new repository with this service manager
        final repository = WeatherRepository(mockServiceManager);

        // Act
        final result = await repository.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error, isA<DataException>());
            expect(error.message, contains('Weather service not initialized'));
          },
          (forecasts) => fail('Should not return success'),
        );
      });

      test('handles unexpected exceptions', () async {
        // Arrange
        when(mockWeatherService.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        )).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await weatherRepository.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error, isA<DataException>());
            expect(error.message, contains('Unexpected error'));
          },
          (forecasts) => fail('Should not return success'),
        );
      });
    });
  });
}
