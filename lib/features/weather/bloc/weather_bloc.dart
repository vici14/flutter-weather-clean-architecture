import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/base/bloc/base_bloc.dart';
import '../../../core/base/bloc/loading_state.dart';
import '../../../core/dependency_injection/service_locator.dart';
import '../../../core/error/AppError.dart';
import '../../../core/services/loading_manager.dart';
import '../../../data/models/weather_forecast.dart';
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
    // Update to loading state
    emit(state.copyWith(
      forecastLoadingState: LoadingState.loading(),
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));

    try {
      final result = await _weatherRepository.getFourDaysForecast(
        lat: event.lat,
        lon: event.lon,
        units: event.units,
      );
      // await Future.delayed(const Duration(seconds: 2));
      if (result.isSuccess && result.data != null) {
        var todayForecast = result.data!.first;

        // filter the data to get only the next 4 days (exclude today)
        var filteredData = result.data!.take(5).skip(1).toList();

        emit(state.copyWith(
          forecastLoadingState: LoadingState<List<DailyForecast>>(
            isLoading: false,
            isLoadedSuccess: true,
            value: result.data,
          ),
          forecast: filteredData,
          todayForecast: todayForecast,
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      } else {
        // Update with error state
        emit(state.copyWith(
          forecastLoadingState: LoadingState.error(
              AppError(message: 'Failed to load forecast: ${result.error}')),
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
      getIt<LoadingManager>().forceHideLoading();

    } catch (e) {
      // Update with error state
      emit(state.copyWith(
        forecastLoadingState: LoadingState.error(
            AppError(message: 'Failed to load forecast: ${e.toString()}')),
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  // Convenience method for UI
  void getWeatherForLocation(
      {required double lat, required double lon, String units = 'metric'}) {
    add(GetWeatherForLocationEvent(lat: lat, lon: lon, units: units));
  }
}
