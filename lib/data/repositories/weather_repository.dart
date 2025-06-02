import 'package:fpdart/fpdart.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/failures/api_failure.dart';
import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/i_weather_repository.dart';
import '../mappers/weather_mapper.dart';
import '../service_manager.dart';
import '../exception/DataException.dart';

class WeatherRepository implements IWeatherRepository {
  final ServiceManager _serviceManager;

  WeatherRepository(ServiceManager serviceManager)
      : _serviceManager = serviceManager;

  @override
  Future<Either<Failure, WeatherEntity>> getWeatherForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  }) async {
    final result = await _serviceManager.weatherService.getWeatherForecast(
      lat: lat,
      lon: lon,
      units: units,
    );

    return result.fold(
      (dataException) => Left(_mapDataExceptionToFailure(dataException)),
      (weatherForecast) => Right(WeatherMapper.toEntity(weatherForecast)),
    );
  }

  @override
  Future<Either<Failure, List<DailyForecastEntity>>> getFourDaysForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  }) async {
    final result = await _serviceManager.weatherService.getFourDaysForecast(
      lat: lat,
      lon: lon,
      units: units,
    );

    return result.fold(
      (dataException) => Left(_mapDataExceptionToFailure(dataException)),
      (dailyForecasts) {
        final entities = <DailyForecastEntity>[];
        for (final forecast in dailyForecasts) {
          entities.add(WeatherMapper.dailyForecastToEntity(forecast));
        }
        return Right(entities);
      },
    );
  }

  Failure _mapDataExceptionToFailure(DataException dataException) {
    final message = dataException.message ?? 'Unknown error occurred';

    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection') ||
        message.toLowerCase().contains('timeout')) {
      return NetworkFailure(message: message);
    }

    if (message.toLowerCase().contains('api key') ||
        message.toLowerCase().contains('unauthorized')) {
      return ApiFailure.invalidApiKey();
    }

    if (message.toLowerCase().contains('not found')) {
      return ApiFailure.notFound();
    }

    if (message.toLowerCase().contains('rate limit') ||
        message.toLowerCase().contains('too many requests')) {
      return ApiFailure.rateLimitExceeded();
    }

    return ApiFailure(message: message);
  }
}
