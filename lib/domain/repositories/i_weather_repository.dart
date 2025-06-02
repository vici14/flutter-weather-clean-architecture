import 'package:fpdart/fpdart.dart';
import '../entities/weather_entity.dart';
import '../failures/failure.dart';

abstract class IWeatherRepository {
  Future<Either<Failure, WeatherEntity>> getWeatherForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  });

  Future<Either<Failure, List<DailyForecastEntity>>> getFourDaysForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  });
}
