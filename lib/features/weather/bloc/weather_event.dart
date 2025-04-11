import '../../../core/base/bloc/base_event.dart';

abstract class WeatherEvent extends BaseEvent {}

class GetWeatherForLocationEvent extends WeatherEvent {
 
  GetWeatherForLocationEvent();
}
