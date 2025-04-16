import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/core/base/bloc/loading_state.dart';
import 'package:weather_app_assignment/core/error/AppError.dart';
import 'package:weather_app_assignment/data/models/weather_forecast.dart';
import 'package:weather_app_assignment/features/weather/bloc/weather_state.dart';

void main() {
  group('WeatherState Tests', () {
    test('initial state has empty forecast', () {
      const state = WeatherState();

      expect(state.forecast, isEmpty);
      expect(state.todayForecast, isNull);
      expect(state.forecastLoadingState.isLoading, isFalse);
      expect(state.forecastLoadingState.isLoadedSuccess, isFalse);
      expect(state.forecastLoadingState.loadError, isNull);
    });

    test('copyWith updates only specified fields', () {
      const initialState = WeatherState(
        timeStamp: 1,
      );

      final forecast = [
        DailyForecast(
          dt: 1624104000,
          sunrise: 1624075200,
          sunset: 1624128000,
          temp: const TempRange(
            day: 25.0,
            min: 18.0,
            max: 28.0,
            night: 20.0,
            eve: 24.0,
            morn: 19.0,
          ),
          weather: [
            const WeatherCondition(
              id: 800,
              main: "Clear",
              description: "clear sky",
              icon: "01d",
            ),
          ],
        ),
      ];

      final todayForecast = DailyForecast(
        dt: 1624104000,
        sunrise: 1624075200,
        sunset: 1624128000,
        temp: const TempRange(
          day: 25.0,
          min: 18.0,
          max: 28.0,
          night: 20.0,
          eve: 24.0,
          morn: 19.0,
        ),
        weather: [
          const WeatherCondition(
            id: 800,
            main: "Clear",
            description: "clear sky",
            icon: "01d",
          ),
        ],
      );

      final newLoadingState = LoadingState<List<DailyForecast>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: forecast,
      );

      final updatedState = initialState.copyWith(
        timeStamp: 2,
        forecastLoadingState: newLoadingState,
        forecast: forecast,
        todayForecast: todayForecast,
      );

      expect(updatedState.timeStamp, 2);
      expect(updatedState.forecastLoadingState, newLoadingState);
      expect(updatedState.forecast, forecast);
      expect(updatedState.todayForecast, todayForecast);
    });

    test('props includes all properties for equality comparison', () {
      final forecast = [
        DailyForecast(
          dt: 1624104000,
          sunrise: 1624075200,
          sunset: 1624128000,
          temp: const TempRange(
            day: 25.0,
            min: 18.0,
            max: 28.0,
            night: 20.0,
            eve: 24.0,
            morn: 19.0,
          ),
          weather: [
            const WeatherCondition(
              id: 800,
              main: "Clear",
              description: "clear sky",
              icon: "01d",
            ),
          ],
        ),
      ];

      final todayForecast = DailyForecast(
        dt: 1624104000,
        sunrise: 1624075200,
        sunset: 1624128000,
        temp: const TempRange(
          day: 25.0,
          min: 18.0,
          max: 28.0,
          night: 20.0,
          eve: 24.0,
          morn: 19.0,
        ),
        weather: [
          const WeatherCondition(
            id: 800,
            main: "Clear",
            description: "clear sky",
            icon: "01d",
          ),
        ],
      );

      final loadingState = LoadingState<List<DailyForecast>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: forecast,
      );

      final state = WeatherState(
        timeStamp: 123456,
        forecastLoadingState: loadingState,
        forecast: forecast,
        todayForecast: todayForecast,
      );

      expect(state.props, [
        123456,
        loadingState,
        forecast,
        todayForecast,
      ]);
    });

    test('hasInitializeError returns true when there is a loading error', () {
      final loadingState = LoadingState<List<DailyForecast>>.error(
        AppError(message: 'Failed to load forecast'),
      );

      final state = WeatherState(
        forecastLoadingState: loadingState,
      );

      expect(state.hasInitializeError, isTrue);
    });

    test('isInitialLoading returns true when forecast is loading', () {
      final loadingState = LoadingState<List<DailyForecast>>.loading();

      final state = WeatherState(
        forecastLoadingState: loadingState,
      );

      expect(state.isInitialLoading, isTrue);
    });

    test('loadingStates returns list of all loading states', () {
      final loadingState = LoadingState<List<DailyForecast>>();

      final state = WeatherState(
        forecastLoadingState: loadingState,
      );

      expect(state.loadingStates, [loadingState]);
    });
  });
}
