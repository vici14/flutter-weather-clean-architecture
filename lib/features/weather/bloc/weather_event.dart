import '../../../core/base/bloc/base_event.dart';

abstract class WeatherEvent extends BaseEvent {}

class GetWeatherForLocationEvent extends WeatherEvent {
  final double lat;
  final double lon;
  final String units;

  GetWeatherForLocationEvent({
    required this.lat,
    required this.lon,
    this.units = 'metric',
  });
}
