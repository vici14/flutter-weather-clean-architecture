import '../../core/service_manager.dart';
import '../services/weather_service.dart';
import 'i_weather_repository.dart';

class WeatherRepository implements IWeatherRepository {
  final ServiceManager _serviceManager;

  WeatherRepository({ServiceManager? serviceManager})
      : _serviceManager = serviceManager ?? ServiceManager();

  @override
  Future<WeatherResult<WeatherForecast>> getWeatherForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  }) {
    return _serviceManager.weatherService.getWeatherForecast(
      lat: lat,
      lon: lon,
      units: units,
    );
  }
}
