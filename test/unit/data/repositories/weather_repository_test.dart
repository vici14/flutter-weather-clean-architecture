import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/data/models/weather_forecast.dart';
import 'package:weather_app_assignment/data/repositories/weather_repository.dart';
import 'package:weather_app_assignment/data/services/weather_service.dart';
import '../../../mocks/mock_generators.mocks.dart';
import '../../../test_helpers/dummy_values.dart';

void main() {
  late WeatherRepository weatherRepository;
  late MockServiceManager mockServiceManager;
  late MockWeatherService mockWeatherService;

  setUp(() {
    // Initialize mocks
    mockServiceManager = MockServiceManager();
    mockWeatherService = MockWeatherService();

    // Setup service manager to return weather service
    when(mockServiceManager.weatherService).thenReturn(mockWeatherService);

    // Create repository with mocked dependencies
    weatherRepository = WeatherRepository(mockServiceManager);

    // Register dummy values
    registerDummyValues();
  });

  group('WeatherRepository Tests', () {
    final mockForecast = WeatherForecast(
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
            id: 800,
            main: 'Clear',
            description: 'clear sky',
            icon: '01d',
          ),
        ],
      ),
      daily: [
        DailyForecast(
          dt: 1627246800,
          sunrise: 1627207155,
          sunset: 1627260014,
          temp: TempRange(
            day: 28.5,
            min: 22.5,
            max: 30.5,
            night: 23.5,
            eve: 27.5,
            morn: 24.5,
          ),
          weather: [
            WeatherCondition(
              id: 800,
              main: 'Clear',
              description: 'clear sky',
              icon: '01d',
            ),
          ],
        ),
      ],
    );

    test('getWeatherForecast should call service and return forecast',
        () async {
      // Arrange
      when(mockWeatherService.getWeatherForecast(
              lat: anyNamed('lat'), lon: anyNamed('lon')))
          .thenAnswer((_) async => Right(mockForecast));

      // Act
      final result = await weatherRepository.getWeatherForecast(
        lat: 40.7128,
        lon: -74.0060,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (error) => fail('Should not return error'),
        (forecast) {
          expect(forecast.lat, 40.7128);
          expect(forecast.lon, -74.0060);
          expect(forecast.timezone, 'America/New_York');
        },
      );
      verify(mockWeatherService.getWeatherForecast(
        lat: 40.7128,
        lon: -74.0060,
        units: 'metric',
      )).called(1);
    });

    test('getWeatherForecast should propagate errors from service', () async {
      // Arrange
      final error = DataException(message: 'Service error');
      when(mockWeatherService.getWeatherForecast(
              lat: anyNamed('lat'), lon: anyNamed('lon')))
          .thenAnswer((_) async => Left(error));

      // Act
      final result = await weatherRepository.getWeatherForecast(
        lat: 40.7128,
        lon: -74.0060,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error.message, 'Service error'),
        (_) => fail('Should return error'),
      );
    });

    final mockDailyForecasts = [
      DailyForecast(
        dt: 1627246800,
        sunrise: 1627207155,
        sunset: 1627260014,
        temp: TempRange(
          day: 28.5,
          min: 22.5,
          max: 30.5,
          night: 23.5,
          eve: 27.5,
          morn: 24.5,
        ),
        weather: [
          WeatherCondition(
            id: 800,
            main: 'Clear',
            description: 'clear sky',
            icon: '01d',
          ),
        ],
      ),
    ];

    test('getFourDaysForecast should call service and return daily forecasts',
        () async {
      // Arrange
      when(mockWeatherService.getFourDaysForecast(
              lat: anyNamed('lat'), lon: anyNamed('lon')))
          .thenAnswer((_) async => Right(mockDailyForecasts));

      // Act
      final result = await weatherRepository.getFourDaysForecast(
        lat: 40.7128,
        lon: -74.0060,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (error) => fail('Should not return error'),
        (forecasts) {
          expect(forecasts.length, 1);
          expect(forecasts.first.dt, 1627246800);
        },
      );
      verify(mockWeatherService.getFourDaysForecast(
        lat: 40.7128,
        lon: -74.0060,
        units: 'metric',
      )).called(1);
    });

    test('getFourDaysForecast should propagate errors from service', () async {
      // Arrange
      final error = DataException(message: 'Service error');
      when(mockWeatherService.getFourDaysForecast(
              lat: anyNamed('lat'), lon: anyNamed('lon')))
          .thenAnswer((_) async => Left(error));

      // Act
      final result = await weatherRepository.getFourDaysForecast(
        lat: 40.7128,
        lon: -74.0060,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error.message, 'Service error'),
        (_) => fail('Should return error'),
      );
    });

    test('weatherRepository handles null service gracefully', () async {
      // Arrange
      MockServiceManager nullServiceManager = MockServiceManager();
      when(nullServiceManager.weatherService)
          .thenThrow(Exception('No service'));
      final repository = WeatherRepository(nullServiceManager);

      // Act
      final result = await repository.getWeatherForecast(
        lat: 40.7128,
        lon: -74.0060,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error.message?.contains('service unavailable'), true),
        (_) => fail('Should return error'),
      );
    });
  });
}
