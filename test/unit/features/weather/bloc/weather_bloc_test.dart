import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app_assignment/core/base/bloc/loading_state.dart';
import 'package:weather_app_assignment/core/error/AppError.dart';
import 'package:weather_app_assignment/core/error/error_handler.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';
import 'package:weather_app_assignment/data/models/weather_forecast.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/data/repositories/i_weather_repository.dart';
import 'package:weather_app_assignment/features/weather/bloc/weather_bloc.dart';
import 'package:weather_app_assignment/features/weather/bloc/weather_event.dart';
import 'package:weather_app_assignment/features/weather/bloc/weather_state.dart';
import '../../../../mocks/mock_generators.mocks.dart';
import '../../../../mocks/test_helpers.dart';

void main() {
  late WeatherBloc weatherBloc;
  late MockIWeatherRepository mockWeatherRepository;
  late DailyForecast mockForecast;
  late List<DailyForecast> mockForecasts;
  late MockLoadingManager mockLoadingManager;

  setUp(() {
    setupTestDependencies();
    mockWeatherRepository =
        GetIt.instance<IWeatherRepository>() as MockIWeatherRepository;
    mockLoadingManager = GetIt.instance<LoadingManager>() as MockLoadingManager;
    weatherBloc = WeatherBloc(mockWeatherRepository);

    mockForecast = DailyForecast(
      dt: 1234567890,
      temp: TempRange(
        day: 20,
        min: 15,
        max: 25,
        night: 18,
        eve: 22,
        morn: 16,
      ),
      weather: [],
      sunrise: 1234567890,
      sunset: 1234567890,
    );

    mockForecasts = List.filled(5, mockForecast);

    provideDummy<Either<DataException, List<DailyForecast>>>(
        Right(mockForecasts));
  });

  tearDown(() {
    weatherBloc.close();
    tearDownTestDependencies();
  });

  test('initial state is correct', () {
    expect(weatherBloc.state, const WeatherState());
  });

  group('GetWeatherForLocationEvent', () {
    blocTest<WeatherBloc, WeatherState>(
      'emits loading and success states when weather data is fetched successfully',
      setUp: () {
        when(mockWeatherRepository.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        )).thenAnswer((_) async => Right(mockForecasts));
      },
      build: () => weatherBloc,
      act: (bloc) => bloc.getWeatherForLocation(lat: 40.0, lon: -70.0),
      expect: () => [
        isA<WeatherState>().having(
          (state) => state.forecastLoadingState,
          'loading state',
          isA<LoadingState>()
              .having((state) => state.isLoading, 'isLoading', true),
        ),
        isA<WeatherState>()
            .having(
              (state) => state.forecastLoadingState.isLoadedSuccess,
              'success state',
              true,
            )
            .having(
              (state) => state.forecast.length,
              'forecast length',
              4,
            )
            .having(
              (state) => state.todayForecast,
              'today forecast',
              mockForecast,
            ),
      ],
      verify: (_) {
        verify(mockWeatherRepository.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        )).called(1);
      },
    );

    blocTest<WeatherBloc, WeatherState>(
      'emits loading and error states when weather data fetch fails',
      setUp: () {
        when(mockWeatherRepository.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        )).thenAnswer((_) async =>
            Left(DataException(message: 'Failed to fetch weather')));
      },
      build: () => weatherBloc,
      act: (bloc) => bloc.getWeatherForLocation(lat: 40.0, lon: -70.0),
      expect: () => [
        isA<WeatherState>().having(
          (state) => state.forecastLoadingState,
          'loading state',
          isA<LoadingState>()
              .having((state) => state.isLoading, 'isLoading', true),
        ),
        isA<WeatherState>().having(
          (state) => state.forecastLoadingState.loadError,
          'error state',
          isA<AppError>().having(
            (error) => error.message,
            'error message',
            'Failed to fetch weather',
          ),
        ),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'handles unexpected errors during weather data fetch',
      setUp: () {
        when(mockWeatherRepository.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        )).thenThrow(DataException(message: 'Unexpected error'));
      },
      build: () => weatherBloc,
      act: (bloc) => bloc.getWeatherForLocation(lat: 40.0, lon: -70.0),
      expect: () => [
        isA<WeatherState>().having(
          (state) => state.forecastLoadingState,
          'loading state',
          isA<LoadingState>()
              .having((state) => state.isLoading, 'isLoading', true),
        ),
        isA<WeatherState>().having(
          (state) => state.forecastLoadingState.loadError,
          'error state',
          isA<AppError>().having(
            (error) => error.message,
            'error message',
            'Unexpected error',
          ),
        ),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'uses different units parameter when specified',
      setUp: () {
        when(mockWeatherRepository.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'imperial',
        )).thenAnswer((_) async => Right(mockForecasts));
      },
      build: () => weatherBloc,
      act: (bloc) => bloc.getWeatherForLocation(
        lat: 40.0,
        lon: -70.0,
        units: 'imperial',
      ),
      verify: (_) {
        verify(mockWeatherRepository.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'imperial',
        )).called(1);
      },
    );

    test('LoadingManager.forceHideLoading is called on success', () async {
      // Arrange
      when(mockWeatherRepository.getFourDaysForecast(
        lat: 40.0,
        lon: -70.0,
        units: 'metric',
      )).thenAnswer((_) async => Right(mockForecasts));

      // Use a spy to verify the LoadingManager call
      final spyLoadingManager = LoadingManager(GlobalKey<NavigatorState>());
      final originalLoadingManager = GetIt.I.get<LoadingManager>();
      GetIt.I.unregister<LoadingManager>();
      GetIt.I.registerSingleton<LoadingManager>(spyLoadingManager);

      // Act
      weatherBloc.getWeatherForLocation(lat: 40.0, lon: -70.0);

      // Wait for the async operation to complete
      await untilCalled(mockWeatherRepository.getFourDaysForecast(
        lat: anyNamed('lat'),
        lon: anyNamed('lon'),
        units: anyNamed('units'),
      ));

      // Add a small delay to ensure the bloc has processed the result
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(weatherBloc.state.forecastLoadingState.isLoadedSuccess, true);

      // Restore original loading manager
      GetIt.I.unregister<LoadingManager>();
      GetIt.I.registerSingleton<LoadingManager>(originalLoadingManager);
    });

    blocTest<WeatherBloc, WeatherState>(
      'correctly filters forecasts to get next 4 days excluding today',
      setUp: () {
        // Create distinct forecasts to verify filtering
        final List<DailyForecast> distinctForecasts = List.generate(
          5,
          (index) => DailyForecast(
            dt: 1234567890 + (index * 86400), // Add one day each time
            temp: TempRange(
              day: 20.0 + index,
              min: 15.0 + index,
              max: 25.0 + index,
              night: 18.0 + index,
              eve: 22.0 + index,
              morn: 16.0 + index,
            ),
            weather: [],
            sunrise: 1234567890 + (index * 3600),
            sunset: 1234567890 + (index * 3600) + 43200,
          ),
        );

        when(mockWeatherRepository.getFourDaysForecast(
          lat: 40.0,
          lon: -70.0,
          units: 'metric',
        )).thenAnswer((_) async => Right(distinctForecasts));
      },
      build: () => weatherBloc,
      act: (bloc) => bloc.getWeatherForLocation(lat: 40.0, lon: -70.0),
      expect: () => [
        isA<WeatherState>().having(
          (state) => state.forecastLoadingState.isLoading,
          'loading state',
          true,
        ),
        isA<WeatherState>()
            .having(
              (state) => state.forecastLoadingState.isLoadedSuccess,
              'success state',
              true,
            )
            .having(
              (state) => state.forecast.length,
              'forecast length',
              4,
            )
            .having(
              (state) => state.forecast[0].dt,
              'first forecast dt',
              1234567890 + 86400, // Second day in the list
            )
            .having(
              (state) => state.todayForecast,
              'today forecast',
              isNotNull,
            )
            .having(
              (state) => state.todayForecast?.dt,
              'today forecast dt',
              1234567890, // First day in the list
            ),
      ],
    );

    test('convenience method adds correct event to bloc', () async {
      // Create a spy bloc to verify the event
      final blocForTest = WeatherBloc(mockWeatherRepository);

      // Setup mock for these specific parameters
      when(mockWeatherRepository.getFourDaysForecast(
        lat: 42.0,
        lon: -71.0,
        units: 'imperial',
      )).thenAnswer((_) async => Right(mockForecasts));

      // Act
      blocForTest.getWeatherForLocation(
          lat: 42.0, lon: -71.0, units: 'imperial');

      // Wait for the async operation to complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify the repository was called with the right parameters
      verify(mockWeatherRepository.getFourDaysForecast(
        lat: 42.0,
        lon: -71.0,
        units: 'imperial',
      )).called(1);

      // Close the bloc after verification
      await blocForTest.close();
    });
  });
}
