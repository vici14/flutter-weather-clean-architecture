import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/base/bloc/base_bloc.dart';
import '../../../data/repositories/i_weather_repository.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends BaseBloc<WeatherEvent, WeatherState> {
  final IWeatherRepository _weatherRepository;

  WeatherBloc(this._weatherRepository) : super(state: const WeatherState()) {
    on<GetWeatherForLocationEvent>(_onGetWeatherForLocation);
  }

  Future<void> _onGetWeatherForLocation(
    GetWeatherForLocationEvent event,
    Emitter<WeatherState> emit,
  ) async {
  }

}
