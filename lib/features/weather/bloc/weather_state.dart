import '../../../core/base/bloc/base_bloc_state.dart';
import '../../../core/base/bloc/loading_state.dart';
import '../../../data/models/weather_forecast.dart';
import 'package:equatable/equatable.dart';

class WeatherState extends BaseBlocState {
  final LoadingState<List<DailyForecast>> forecastLoadingState;
  final List<DailyForecast> forecast;
  final DailyForecast? todayForecast;
  const WeatherState({
    super.timeStamp = 1,
    this.forecastLoadingState = const LoadingState(),
    this.forecast = const [],
    this.todayForecast,
  });

  WeatherState copyWith({
    int? timeStamp,
    String? baseError,
    LoadingState<List<DailyForecast>>? forecastLoadingState,
    List<DailyForecast>? forecast,
    DailyForecast? todayForecast,
  }) {
    return WeatherState(
      timeStamp: timeStamp ?? this.timeStamp,
      forecastLoadingState: forecastLoadingState ?? this.forecastLoadingState,
      forecast: forecast ?? this.forecast,
      todayForecast: todayForecast ?? this.todayForecast,
    );
  }

  @override
  List<Object> get props => [
        timeStamp,
        forecastLoadingState,
        forecast,
        todayForecast ??
            DailyForecast(
              dt: 0,
              temp: TempRange(
                day: 0,
                min: 0,
                max: 0,
                night: 0,
                eve: 0,
                morn: 0,
              ),
              weather: [],
              sunrise: 0,
              sunset: 0,
            ),
      ];

  @override
  bool get hasInitializeError =>
      !forecastLoadingState.isLoading && forecastLoadingState.loadError != null;

  @override
  bool get isInitialLoading => forecastLoadingState.isLoading;

  @override
  List<LoadingState> get loadingStates => [forecastLoadingState];
}
