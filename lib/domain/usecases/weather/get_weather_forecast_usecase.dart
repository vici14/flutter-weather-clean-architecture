import 'package:fpdart/fpdart.dart';
import '../../entities/weather_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/i_weather_repository.dart';
import '../base_usecase.dart';

class GetWeatherForecastParams {
  final double lat;
  final double lon;
  final String units;

  const GetWeatherForecastParams({
    required this.lat,
    required this.lon,
    this.units = 'metric',
  });
}

class GetWeatherForecastUseCase
    implements UseCase<WeatherEntity, GetWeatherForecastParams> {
  final IWeatherRepository repository;

  const GetWeatherForecastUseCase(this.repository);

  @override
  Future<Either<Failure, WeatherEntity>> call(
      GetWeatherForecastParams params) async {
    return await repository.getWeatherForecast(
      lat: params.lat,
      lon: params.lon,
      units: params.units,
    );
  }
}
