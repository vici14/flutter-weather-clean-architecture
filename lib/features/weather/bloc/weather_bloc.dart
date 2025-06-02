import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';

import '../../../core/base/bloc/base_bloc.dart';
import '../../../core/base/bloc/loading_state.dart';
import '../../../core/dependency_injection/service_locator.dart';
import '../../../core/error/AppError.dart';
import '../../../core/services/loading_manager.dart';
import '../../../data/models/weather_forecast.dart';
import '../../../data/mappers/weather_mapper.dart';
import '../../../domain/usecases/weather/get_four_days_forecast_usecase.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends BaseBloc<WeatherEvent, WeatherState> {
  final GetFourDaysForecastUseCase _getFourDaysForecastUseCase;

  WeatherBloc({
    required GetFourDaysForecastUseCase getFourDaysForecastUseCase,
  })  : _getFourDaysForecastUseCase = getFourDaysForecastUseCase,
        super(state: const WeatherState()) {
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
      final result = await _getFourDaysForecastUseCase(
        GetFourDaysForecastParams(
          lat: event.lat,
          lon: event.lon,
          units: event.units,
        ),
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            forecastLoadingState: LoadingState.error(
              AppError(message: failure.message),
            ),
            timeStamp: DateTime.now().millisecondsSinceEpoch,
          ));
        },
        (forecastEntities) {
          final forecasts = forecastEntities
              .map((entity) => WeatherMapper.dailyForecastToModel(entity))
              .toList();

          print(
              "result ${forecasts.map((e) => '${getDayName(e.dt)} -"avg:":${e.temp.avgTemp}- max: ${e.temp.max} -- min: ${e.temp.min}').join("\n")}");

          if (forecasts.isNotEmpty) {
            var todayForecast = forecasts.first;
            print(
                "todayForecast ${getDayName(todayForecast.dt)} --- avg: ${todayForecast.temp.avgTemp} -- max: ${todayForecast.temp.max} -- min: ${todayForecast.temp.min} ");

            var filteredData = forecasts.take(5).skip(1).toList();
            print(
                "filteredData ${filteredData.map((e) => '${getDayName(e.dt)} -"avg:":${e.temp.avgTemp}- max: ${e.temp.max} -- min: ${e.temp.min}').join("\n")}");

            emit(state.copyWith(
              forecastLoadingState: LoadingState<List<DailyForecast>>(
                isLoading: false,
                isLoadedSuccess: true,
                value: forecasts,
              ),
              forecast: filteredData,
              todayForecast: todayForecast,
              timeStamp: DateTime.now().millisecondsSinceEpoch,
            ));
          } else {
            emit(state.copyWith(
              forecastLoadingState: LoadingState.error(
                AppError(message: 'No forecast data available'),
              ),
              timeStamp: DateTime.now().millisecondsSinceEpoch,
            ));
          }
        },
      );

      getIt<LoadingManager>().forceHideLoading();
    } catch (e) {
      // Update with error state
      emit(state.copyWith(
        forecastLoadingState: LoadingState.error(
          AppError(message: e.toString()),
        ),
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  // Convenience method for UI
  void getWeatherForLocation(
      {required double lat, required double lon, String units = 'metric'}) {
    add(GetWeatherForLocationEvent(lat: lat, lon: lon, units: units));
  }

  String getDayName(int timestamp) {
    return DateFormat('EEEE')
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
  }
}
