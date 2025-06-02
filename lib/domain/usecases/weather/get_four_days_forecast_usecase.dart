import 'package:fpdart/fpdart.dart';
import '../../entities/weather_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/i_weather_repository.dart';
import '../base_usecase.dart';

class GetFourDaysForecastParams {
  final double lat;
  final double lon;
  final String units;

  const GetFourDaysForecastParams({
    required this.lat,
    required this.lon,
    this.units = 'metric',
  });
}

class GetFourDaysForecastUseCase
    implements UseCase<List<DailyForecastEntity>, GetFourDaysForecastParams> {
  final IWeatherRepository repository;

  const GetFourDaysForecastUseCase(this.repository);

  @override
  Future<Either<Failure, List<DailyForecastEntity>>> call(
      GetFourDaysForecastParams params) async {
    return await repository.getFourDaysForecast(
      lat: params.lat,
      lon: params.lon,
      units: params.units,
    );
  }
}
