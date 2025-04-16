import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:async'; // Add StreamController import
import 'package:weather_app_assignment/core/base/bloc/loading_state.dart';
import 'package:weather_app_assignment/core/error/AppError.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';
import 'package:weather_app_assignment/core/services/network_checker.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/data/models/weather_forecast.dart';
import 'package:weather_app_assignment/data/repositories/i_location_repository.dart';
import 'package:weather_app_assignment/data/repositories/i_weather_repository.dart';
import 'package:weather_app_assignment/features/location/bloc/location_bloc.dart';
import 'package:weather_app_assignment/features/location/bloc/location_event.dart';
import 'package:weather_app_assignment/features/location/bloc/location_state.dart';
import 'package:weather_app_assignment/features/weather/bloc/weather_bloc.dart';
import 'package:weather_app_assignment/features/weather/bloc/weather_event.dart';
import 'package:weather_app_assignment/features/weather/bloc/weather_state.dart';
import 'package:weather_app_assignment/features/weather/pages/weather_page.dart';
import 'package:weather_app_assignment/core/widgets/error_screen.dart';

import '../../../mocks/mock_generators.mocks.dart';
import '../../../mocks/test_helpers.dart';

void main() {
  late WeatherBloc weatherBloc;
  late LocationBloc locationBloc;
  late MockIWeatherRepository mockWeatherRepository;
  late MockILocationRepository mockLocationRepository;
  late MockNetworkChecker mockNetworkChecker;
  late MockLoadingManager mockLoadingManager;

  final testDailyForecasts = [
    DailyForecast(
      dt: 1692021600, // Monday timestamp
      sunrise: 1692002400,
      sunset: 1692052800,
      temp: const TempRange(
        day: 25.5,
        min: 20.0,
        max: 30.0,
        night: 22.0,
        eve: 24.0,
        morn: 21.0,
      ),
      humidity: 60,
      windSpeed: 10.5,
      weather: [
        const WeatherCondition(
          id: 800,
          main: 'Clear',
          description: 'Sunny',
          icon: '01d',
        ),
      ],
    ),
    DailyForecast(
      dt: 1692108000, // Tuesday timestamp
      sunrise: 1692088800,
      sunset: 1692139200,
      temp: const TempRange(
        day: 24.0,
        min: 19.0,
        max: 28.0,
        night: 20.0,
        eve: 23.0,
        morn: 19.5,
      ),
      humidity: 65,
      windSpeed: 8.2,
      weather: [
        const WeatherCondition(
          id: 801,
          main: 'Clouds',
          description: 'Partly cloudy',
          icon: '02d',
        ),
      ],
    ),
    DailyForecast(
      dt: 1692194400, // Wednesday timestamp
      sunrise: 1692175200,
      sunset: 1692225600,
      temp: const TempRange(
        day: 22.5,
        min: 18.0,
        max: 26.0,
        night: 19.0,
        eve: 21.0,
        morn: 18.5,
      ),
      humidity: 75,
      windSpeed: 12.0,
      weather: [
        const WeatherCondition(
          id: 500,
          main: 'Rain',
          description: 'Rainy',
          icon: '10d',
        ),
      ],
    ),
    DailyForecast(
      dt: 1692280800, // Thursday timestamp
      sunrise: 1692261600,
      sunset: 1692312000,
      temp: const TempRange(
        day: 23.0,
        min: 18.5,
        max: 27.0,
        night: 19.5,
        eve: 22.0,
        morn: 19.0,
      ),
      humidity: 70,
      windSpeed: 9.5,
      weather: [
        const WeatherCondition(
          id: 802,
          main: 'Clouds',
          description: 'Cloudy',
          icon: '03d',
        ),
      ],
    ),
  ];

  setUp(() {
    setupTestDependencies();

    mockWeatherRepository =
        GetIt.instance<IWeatherRepository>() as MockIWeatherRepository;
    mockLocationRepository =
        GetIt.instance<ILocationRepository>() as MockILocationRepository;
    mockNetworkChecker = GetIt.instance<NetworkChecker>() as MockNetworkChecker;
    mockLoadingManager = GetIt.instance<LoadingManager>() as MockLoadingManager;

    // Use mocked blocs from GetIt instead of creating new ones
    weatherBloc = GetIt.instance<WeatherBloc>() as MockWeatherBloc;
    locationBloc = GetIt.instance<LocationBloc>() as MockLocationBloc;

    // Setup network checker
    when(mockNetworkChecker.hasConnection).thenReturn(true);
    when(mockNetworkChecker.connectionStatus)
        .thenAnswer((_) => Stream.value(true));

    // Setup default location state with all required properties
    final mockLocationState = LocationState(
      countriesLoadingState: const LoadingState<List<Country>>(),
      searchLoadingState: const LoadingState<List<Country>>(),
      countryDetailsLoadingState: const LoadingState<Country>(),
      countries: const [],
      allCountries: const [],
      timeStamp: 1,
      errorMessage: '',
    );

    when(locationBloc.state).thenReturn(mockLocationState);

    // Setup default weather state
    final mockWeatherState = WeatherState(
      forecastLoadingState: const LoadingState<List<DailyForecast>>(),
      forecast: const [],
      timeStamp: 1,
    );

    when(weatherBloc.state).thenReturn(mockWeatherState);

    // Setup loading manager stubs
    when(mockLoadingManager.showLoading()).thenAnswer((_) => Future.value());
    when(mockLoadingManager.hideLoading()).thenAnswer((_) => Future.value());
  });

  tearDown(() {
    weatherBloc.close();
    locationBloc.close();
    tearDownTestDependencies();
  });

  Widget createTestableWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          BlocProvider<WeatherBloc>.value(value: weatherBloc),
          BlocProvider<LocationBloc>.value(value: locationBloc),
          Provider<NetworkChecker>.value(value: mockNetworkChecker),
          Provider<LoadingManager>.value(value: mockLoadingManager),
        ],
        child: const WeatherPage(),
      ),
    );
  }

  testWidgets('WeatherPage should render loading state correctly',
      (WidgetTester tester) async {
    // Set up initial loading state
    final loadingLocationState = LocationState(
      countriesLoadingState: const LoadingState<List<Country>>(),
      searchLoadingState: const LoadingState<List<Country>>(),
      countryDetailsLoadingState: LoadingState<Country>.loading(),
      countries: const [],
      allCountries: const [],
    );

    when(locationBloc.state).thenReturn(loadingLocationState);

    // Build page with dependencies
    await tester.pumpWidget(createTestableWidget());

    // Verify the bloc is in loading state
    expect(locationBloc.state.isInitialLoading, isTrue);

    // Wait for the widget to rebuild
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets(
      'WeatherPage should render weather data when location data is available',
      (WidgetTester tester) async {
    // Setup location bloc with a selected country
    final country = Country(
      id: 1,
      name: 'United States',
      iso2: 'US',
      latitude: '37.0902',
      longitude: '-95.7129',
    );

    // Mock successful weather data
    when(mockWeatherRepository.getFourDaysForecast(
      lat: anyNamed('lat'),
      lon: anyNamed('lon'),
      units: anyNamed('units'),
    )).thenAnswer((_) async => Right(testDailyForecasts));

    // Mock successful country details
    when(mockLocationRepository.getCountryDetails(any))
        .thenAnswer((_) async => Right(country));

    // Build page with dependencies
    await tester.pumpWidget(createTestableWidget());

    // Select a country to trigger weather data loading
    locationBloc.add(CountrySelectedEvent(country));

    // Wait for async operations to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Expect weather details page to be shown with title
    expect(find.text('Weather Details'), findsOneWidget);
  });

  // Test Category 1: Error State Testing
  testWidgets('WeatherPage should show error state when API fails',
      (WidgetTester tester) async {
    // Setup location bloc with a selected country
    final country = Country(
      id: 1,
      name: 'United States',
      iso2: 'US',
      latitude: '37.0902',
      longitude: '-95.7129',
    );

    // Setup location state with successful country details
    final locationStateWithCountry = LocationState(
      countriesLoadingState: const LoadingState<List<Country>>(),
      searchLoadingState: const LoadingState<List<Country>>(),
      countryDetailsLoadingState: LoadingState<Country>(
        isLoading: false,
        isLoadedSuccess: true,
        value: country,
      ),
      countryDetails: country,
      countries: const [],
      allCountries: const [],
    );

    when(locationBloc.state).thenReturn(locationStateWithCountry);

    // Mock weather API to fail with a specific error
    when(mockWeatherRepository.getFourDaysForecast(
      lat: anyNamed('lat'),
      lon: anyNamed('lon'),
      units: anyNamed('units'),
    )).thenAnswer((_) async =>
        Left(DataException(message: 'Failed to get 4-day forecast')));

    // Setup weather state with error
    final weatherStateWithError = WeatherState(
      forecastLoadingState: LoadingState<List<DailyForecast>>.error(
        AppError(message: 'Failed to get 4-day forecast'),
      ),
      forecast: const [],
    );

    when(weatherBloc.state).thenReturn(weatherStateWithError);

    // Build page with dependencies
    await tester.pumpWidget(createTestableWidget());

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify error state in bloc
    expect(weatherBloc.state.hasInitializeError, isTrue);
    expect(weatherBloc.state.forecastLoadingState.loadError, isNotNull);
    expect(weatherBloc.state.forecastLoadingState.loadError?.message,
        'Failed to get 4-day forecast');
  });

  // Test Category 2: Empty Data State Testing
  testWidgets('WeatherPage should handle empty forecast data',
      (WidgetTester tester) async {
    // Setup location bloc with a selected country
    final country = Country(
      id: 1,
      name: 'United States',
      iso2: 'US',
      latitude: '37.0902',
      longitude: '-95.7129',
    );

    // Setup location state with successful country details
    final locationStateWithCountry = LocationState(
      countriesLoadingState: const LoadingState<List<Country>>(),
      searchLoadingState: const LoadingState<List<Country>>(),
      countryDetailsLoadingState: LoadingState<Country>(
        isLoading: false,
        isLoadedSuccess: true,
        value: country,
      ),
      countryDetails: country,
      countries: const [],
      allCountries: const [],
    );

    when(locationBloc.state).thenReturn(locationStateWithCountry);

    // Setup weather state with empty but successful forecast
    final weatherStateWithEmptyForecast = WeatherState(
      forecastLoadingState: LoadingState<List<DailyForecast>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: [],
      ),
      forecast: [],
    );

    when(weatherBloc.state).thenReturn(weatherStateWithEmptyForecast);

    // Build the widget
    await tester.pumpWidget(createTestableWidget());

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify empty state
    expect(weatherBloc.state.forecastLoadingState.isLoadedSuccess, isTrue);
    expect(weatherBloc.state.forecast.isEmpty, isTrue);
  });

  // Test Category 3: Loading State Progression
  testWidgets('WeatherPage should show loading states correctly',
      (WidgetTester tester) async {
    // Setup initial state
    final initialState = LocationState(
      countriesLoadingState: const LoadingState<List<Country>>(),
      searchLoadingState: const LoadingState<List<Country>>(),
      countryDetailsLoadingState: const LoadingState<Country>(),
      countries: const [],
      allCountries: const [],
    );

    when(locationBloc.state).thenReturn(initialState);

    // Build page with dependencies
    await tester.pumpWidget(createTestableWidget());

    // Emit loading state for country details
    final loadingState = LocationState(
      countriesLoadingState: const LoadingState<List<Country>>(),
      searchLoadingState: const LoadingState<List<Country>>(),
      countryDetailsLoadingState: LoadingState<Country>.loading(),
      countries: const [],
      allCountries: const [],
    );

    when(locationBloc.state).thenReturn(loadingState);
    locationBloc.emit(loadingState);

    await tester.pump();

    // Verify location bloc is in loading state
    expect(locationBloc.state.isInitialLoading, isTrue);

    // Complete loading with successful data
    final country = Country(
      id: 1,
      name: 'United States',
      iso2: 'US',
      latitude: '37.0902',
      longitude: '-95.7129',
    );

    final successState = LocationState(
      countriesLoadingState: const LoadingState<List<Country>>(),
      searchLoadingState: const LoadingState<List<Country>>(),
      countryDetailsLoadingState: LoadingState<Country>(
        isLoading: false,
        isLoadedSuccess: true,
        value: country,
      ),
      countryDetails: country,
      countries: const [],
      allCountries: const [],
    );

    when(locationBloc.state).thenReturn(successState);
    locationBloc.emit(successState);

    // Also set the weather loading state
    final weatherLoadingState = WeatherState(
      forecastLoadingState: LoadingState<List<DailyForecast>>.loading(),
      forecast: const [],
    );

    when(weatherBloc.state).thenReturn(weatherLoadingState);
    weatherBloc.emit(weatherLoadingState);

    await tester.pump();

    // Verify weather bloc is in loading state
    expect(weatherBloc.state.isInitialLoading, isTrue);

    // Now complete weather loading
    final weatherSuccessState = WeatherState(
      forecastLoadingState: LoadingState<List<DailyForecast>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: testDailyForecasts,
      ),
      forecast: testDailyForecasts,
    );

    when(weatherBloc.state).thenReturn(weatherSuccessState);
    weatherBloc.emit(weatherSuccessState);

    // Wait for loading to complete
    await tester.pump();

    // Verify weather state is no longer loading
    expect(weatherBloc.state.isInitialLoading, isFalse);
    expect(weatherBloc.state.forecastLoadingState.isLoadedSuccess, isTrue);
  });

  testWidgets(
      'WeatherPage animation controllers should be initialized correctly',
      (WidgetTester tester) async {
    // Create a weather state with loaded forecast
    final loadedWeatherState = WeatherState(
      forecastLoadingState: LoadingState<List<DailyForecast>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: testDailyForecasts,
      ),
      forecast: testDailyForecasts,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    );

    // Create a location state with loaded country
    final countryDetails = Country(
      id: 1,
      name: 'United States',
      iso2: 'US',
      latitude: '40.7128',
      longitude: '-74.0060',
    );

    final loadedLocationState = LocationState(
      countriesLoadingState: const LoadingState<List<Country>>(),
      searchLoadingState: const LoadingState<List<Country>>(),
      countryDetailsLoadingState: LoadingState<Country>(
        isLoading: false,
        isLoadedSuccess: true,
        value: countryDetails,
      ),
      countries: const [],
      allCountries: const [],
      selectedCountry: countryDetails,
      countryDetails: countryDetails,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      errorMessage: '',
    );

    when(weatherBloc.state).thenReturn(loadedWeatherState);
    when(locationBloc.state).thenReturn(loadedLocationState);

    // Add stream behavior for animation to work
    when(weatherBloc.stream)
        .thenAnswer((_) => Stream.value(loadedWeatherState));
    when(locationBloc.stream)
        .thenAnswer((_) => Stream.value(loadedLocationState));

    // Render the widget
    await tester.pumpWidget(createTestableWidget());

    // Initial frame
    await tester.pump();

    // Verify animations have started (forecast data is loaded)
    expect(find.text('United States'), findsOneWidget);
    expect(find.text('25°'), findsOneWidget);

    // Animation in progress
    await tester.pump(const Duration(milliseconds: 300));

    // Verify forecast items are displayed after animation
    expect(find.text('Monday'), findsOneWidget);

    // Complete animation
    await tester.pump(const Duration(milliseconds: 700));

    // Verify all forecasts are visible
    expect(find.text('Tuesday'), findsOneWidget);
    expect(find.text('Wednesday'), findsOneWidget);
    expect(find.text('Thursday'), findsOneWidget);
  });

  testWidgets(
      'WeatherPage should fetch country details and weather data on initialization',
      (WidgetTester tester) async {
    final selectedCountry = Country(
      id: 2,
      name: 'Germany',
      iso2: 'DE',
    );

    // Create a location state with a selected country
    final locationStateWithSelectedCountry = LocationState(
      countriesLoadingState: const LoadingState<List<Country>>(),
      searchLoadingState: const LoadingState<List<Country>>(),
      countryDetailsLoadingState: const LoadingState<Country>(),
      countries: const [],
      allCountries: const [],
      selectedCountry: selectedCountry,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      errorMessage: '',
    );

    when(locationBloc.state).thenReturn(locationStateWithSelectedCountry);

    // Render the widget
    await tester.pumpWidget(createTestableWidget());

    // Verify getCountryDetails was called with the correct ISO code
    verify(locationBloc.getCountryDetails('DE')).called(1);
  });

  testWidgets(
      'WeatherPage should fetch weather data when country details are loaded',
      (WidgetTester tester) async {
    // First, create a state with just a selected country
    final selectedCountry = Country(
      id: 3,
      name: 'France',
      iso2: 'FR',
    );

    final initialLocationState = LocationState(
      countriesLoadingState: const LoadingState<List<Country>>(),
      searchLoadingState: const LoadingState<List<Country>>(),
      countryDetailsLoadingState: const LoadingState<Country>(),
      countries: const [],
      allCountries: const [],
      selectedCountry: selectedCountry,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      errorMessage: '',
    );

    // Create a stream controller to emit state changes
    final locationStateController = StreamController<LocationState>();

    // Initial state
    when(locationBloc.state).thenReturn(initialLocationState);
    when(locationBloc.stream).thenAnswer((_) => locationStateController.stream);

    // Render the widget
    await tester.pumpWidget(createTestableWidget());

    // Prepare country details to be loaded
    final countryWithDetails = Country(
      id: 3,
      name: 'France',
      iso2: 'FR',
      latitude: '48.8566',
      longitude: '2.3522',
    );

    final locationStateWithDetails = LocationState(
      countriesLoadingState: const LoadingState<List<Country>>(),
      searchLoadingState: const LoadingState<List<Country>>(),
      countryDetailsLoadingState: LoadingState<Country>(
        isLoading: false,
        isLoadedSuccess: true,
        value: countryWithDetails,
      ),
      countries: const [],
      allCountries: const [],
      selectedCountry: countryWithDetails,
      countryDetails: countryWithDetails,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      errorMessage: '',
    );

    // Update state to include country details
    when(locationBloc.state).thenReturn(locationStateWithDetails);
    locationStateController.add(locationStateWithDetails);

    // Pump to process the new state
    await tester.pump();

    // Verify weather data is fetched with the correct coordinates
    verify(weatherBloc.getWeatherForLocation(
      lat: 48.8566,
      lon: 2.3522,
    )).called(1);

    // Clean up
    await locationStateController.close();
  });

  testWidgets('WeatherPage should handle errors and display error screen',
      (WidgetTester tester) async {
    // Create an error state for weather
    final errorWeatherState = WeatherState(
      forecastLoadingState: LoadingState<List<DailyForecast>>.error(
        AppError(message: 'Failed to load weather data'),
      ),
      forecast: const [],
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    );

    when(weatherBloc.state).thenReturn(errorWeatherState);
    when(weatherBloc.stream).thenAnswer((_) => Stream.value(errorWeatherState));

    // Render the widget
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    // Verify error screen is displayed
    expect(find.byType(ErrorScreen), findsOneWidget);
    expect(find.text('Failed to load weather data'), findsOneWidget);

    // Verify retry button is available
    expect(find.text('Retry'), findsOneWidget);

    // Tap retry button
    await tester.tap(find.text('Retry'));
    await tester.pump();

    // Verify country details are fetched again
    verify(locationBloc.getCountryDetails(anyNamed('iso2Code') ?? ''))
        .called(greaterThanOrEqualTo(1));
  });

  testWidgets('WeatherPage should rebuild UI when stream emits a new state',
      (WidgetTester tester) async {
    // Initial empty state
    final initialWeatherState = WeatherState(
      forecastLoadingState: const LoadingState<List<DailyForecast>>(),
      forecast: const [],
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    );

    final weatherStateController = StreamController<WeatherState>();

    when(weatherBloc.state).thenReturn(initialWeatherState);
    when(weatherBloc.stream).thenAnswer((_) => weatherStateController.stream);

    // Render the widget with empty forecast
    await tester.pumpWidget(createTestableWidget());
    await tester.pump();

    // Verify no forecast data initially
    expect(find.text('--°'), findsOneWidget);
    expect(find.text('No forecast data available'), findsOneWidget);

    // Create state with forecast data
    final loadedWeatherState = WeatherState(
      forecastLoadingState: LoadingState<List<DailyForecast>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: testDailyForecasts,
      ),
      forecast: testDailyForecasts,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    );

    // Update the state
    when(weatherBloc.state).thenReturn(loadedWeatherState);
    weatherStateController.add(loadedWeatherState);

    // Pump to process new state
    await tester.pump();
    await tester
        .pump(const Duration(milliseconds: 1000)); // Wait for animations

    // Verify forecast data is displayed
    expect(find.text('25°'), findsOneWidget);
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Tuesday'), findsOneWidget);

    // Clean up
    await weatherStateController.close();
  });
}
