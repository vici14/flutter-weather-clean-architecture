import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:weather_app_assignment/data/repositories/weather_repository.dart';
import 'package:weather_app_assignment/data/service_manager.dart';
import 'package:weather_app_assignment/data/services/weather_service.dart';
import 'package:weather_app_assignment/data/models/weather_forecast.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/data/api_client.dart';

// Simple mock classes
class MockWeatherService implements WeatherService {
  bool failGetWeatherForecast = false;
  bool failGetFourDaysForecast = false;

  @override
  Future<Either<DataException, WeatherForecast>> getWeatherForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  }) async {
    if (failGetWeatherForecast) {
      return left(DataException(message: 'Failed to load weather forecast'));
    }

    return right(WeatherForecast(
      lat: lat,
      lon: lon,
      timezone: 'America/Los_Angeles',
      timezoneOffset: -25200,
      daily: [
        const DailyForecast(
          dt: 1617984000,
          sunrise: 1617962100,
          sunset: 1618009793,
          temp: TempRange(
            day: 15.23,
            min: 10.54,
            max: 16.02,
            night: 10.54,
            eve: 13.09,
            morn: 11.32,
          ),
          feelsLike: FeelsLike(
            day: 14.53,
            night: 9.79,
            eve: 12.45,
            morn: 10.32,
          ),
          pressure: 1018,
          humidity: 71,
          dewPoint: 10.2,
          windSpeed: 3.06,
          windDeg: 225,
          weather: [
            WeatherCondition(
              id: 804,
              main: 'Clouds',
              description: 'overcast clouds',
              icon: '04d',
            ),
          ],
          clouds: 90,
          pop: 0.2,
          uvi: 6.54,
        ),
      ],
    ));
  }

  @override
  Future<Either<DataException, List<DailyForecast>>> getFourDaysForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  }) async {
    if (failGetFourDaysForecast) {
      return left(DataException(message: 'Failed to load forecast'));
    }

    return right([
      DailyForecast(
        dt: 1617984000,
        sunrise: 1617962100,
        sunset: 1618009793,
        temp: TempRange(
          day: 15.23,
          min: 10.54,
          max: 16.02,
          night: 10.54,
          eve: 13.09,
          morn: 11.32,
        ),
        feelsLike: FeelsLike(
          day: 14.53,
          night: 9.79,
          eve: 12.45,
          morn: 10.32,
        ),
        pressure: 1018,
        humidity: 71,
        dewPoint: 10.2,
        windSpeed: 3.06,
        windDeg: 225,
        weather: [
          WeatherCondition(
            id: 804,
            main: 'Clouds',
            description: 'overcast clouds',
            icon: '04d',
          ),
        ],
        clouds: 90,
        pop: 0.2,
        uvi: 6.54,
      ),
      DailyForecast(
        dt: 1618070400,
        sunrise: 1618048380,
        sunset: 1618096249,
        temp: TempRange(
          day: 16.78,
          min: 11.65,
          max: 17.25,
          night: 11.65,
          eve: 14.32,
          morn: 12.45,
        ),
        feelsLike: FeelsLike(
          day: 15.98,
          night: 10.85,
          eve: 13.65,
          morn: 11.45,
        ),
        pressure: 1020,
        humidity: 68,
        dewPoint: 9.8,
        windSpeed: 2.75,
        windDeg: 220,
        weather: [
          WeatherCondition(
            id: 801,
            main: 'Clouds',
            description: 'few clouds',
            icon: '02d',
          ),
        ],
        clouds: 20,
        pop: 0.0,
        uvi: 7.12,
      ),
    ]);
  }

  @override
  ApiClient get client => throw UnimplementedError();
}

class MockServiceManager implements ServiceManager {
  final MockWeatherService _weatherService;

  MockServiceManager(this._weatherService);

  @override
  WeatherService get weatherService => _weatherService;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockWeatherService mockWeatherService;
  late MockServiceManager mockServiceManager;
  late WeatherRepository weatherRepository;

  const testLat = 37.7749;
  const testLon = -122.4194;
  const testUnits = 'metric';

  setUp(() {
    mockWeatherService = MockWeatherService();
    mockServiceManager = MockServiceManager(mockWeatherService);
    weatherRepository = WeatherRepository(mockServiceManager);
  });

  group('getWeatherForecast', () {
    test('returns weather forecast when service call is successful', () async {
      // Act
      final result = await weatherRepository.getWeatherForecast(
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
          expect(forecast.daily.length, equals(1));
          expect(forecast.daily[0].temp.day, equals(15.23));
        },
      );
    });

    test('returns DataException when service call fails', () async {
      // Arrange
      mockWeatherService.failGetWeatherForecast = true;

      // Act
      final result = await weatherRepository.getWeatherForecast(
        lat: testLat,
        lon: testLon,
        units: testUnits,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(exception.message, equals('Failed to load weather forecast'));
        },
        (forecast) => fail('Should not return forecast'),
      );
    });
  });

  group('getFourDaysForecast', () {
    test('returns four days forecast when service call is successful',
        () async {
      // Act
      final result = await weatherRepository.getFourDaysForecast(
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

    test('returns DataException when service call fails', () async {
      // Arrange
      mockWeatherService.failGetFourDaysForecast = true;

      // Act
      final result = await weatherRepository.getFourDaysForecast(
        lat: testLat,
        lon: testLon,
        units: testUnits,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(exception.message, equals('Failed to load forecast'));
        },
        (forecasts) => fail('Should not return forecasts'),
      );
    });
  });
}
