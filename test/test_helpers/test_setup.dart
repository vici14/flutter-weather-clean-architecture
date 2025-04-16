import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/core/dependency_injection/service_locator.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';
import 'package:weather_app_assignment/core/services/network_checker.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/features/location/bloc/location_bloc.dart';
import 'package:weather_app_assignment/features/weather/bloc/weather_bloc.dart';
import '../mocks/mock_generators.mocks.dart';
import 'package:mockito/mockito.dart';
import 'dummy_values.dart';

/// Result class for location test setup
class LocationTestSetup {
  final LocationBloc bloc;
  final MockILocationRepository repository;
  final MockNetworkChecker networkChecker;
  final MockLoadingManager loadingManager;

  LocationTestSetup(
      this.bloc, this.repository, this.networkChecker, this.loadingManager);
}

/// Result class for weather test setup
class WeatherTestSetup {
  final WeatherBloc bloc;
  final MockIWeatherRepository repository;
  final MockNetworkChecker networkChecker;
  final MockLoadingManager loadingManager;

  WeatherTestSetup(
      this.bloc, this.repository, this.networkChecker, this.loadingManager);
}

/// Helper class to setup consistent test environment
class TestSetup {
  static final GetIt _getIt = GetIt.instance;

  /// Setup for widget tests
  static void setupWidgetTest() {
    TestWidgetsFlutterBinding.ensureInitialized();
  }

  /// Setup test dependencies for location feature
  static LocationTestSetup setupLocationTest() {
    // Reset GetIt to avoid conflicts between tests
    resetGetIt();

    // Create mocks
    final mockLocationRepository = MockILocationRepository();
    final mockNetworkChecker = MockNetworkChecker();
    final mockLoadingManager = MockLoadingManager();
    final locationBloc = LocationBloc(mockLocationRepository);

    // Configure mock behavior
    when(mockNetworkChecker.hasConnection).thenReturn(true);
    when(mockNetworkChecker.connectionStatus)
        .thenAnswer((_) => Stream.value(true));
    when(mockNetworkChecker.checkConnection()).thenAnswer((_) async => true);

    // Register common dependencies
    _getIt.registerSingleton<NetworkChecker>(mockNetworkChecker);
    _getIt.registerSingleton<LoadingManager>(mockLoadingManager);
    _getIt.registerSingleton<LocationBloc>(locationBloc);

    // Provide dummy values for Either types
    registerDummyValues();

    return LocationTestSetup(locationBloc, mockLocationRepository,
        mockNetworkChecker, mockLoadingManager);
  }

  /// Setup test dependencies for weather feature
  static WeatherTestSetup setupWeatherTest() {
    // Reset GetIt to avoid conflicts between tests
    resetGetIt();

    // Create mocks
    final mockWeatherRepository = MockIWeatherRepository();
    final mockNetworkChecker = MockNetworkChecker();
    final mockLoadingManager = MockLoadingManager();
    final weatherBloc = WeatherBloc(mockWeatherRepository);

    // Configure mock behavior
    when(mockNetworkChecker.hasConnection).thenReturn(true);
    when(mockNetworkChecker.connectionStatus)
        .thenAnswer((_) => Stream.value(true));
    when(mockNetworkChecker.checkConnection()).thenAnswer((_) async => true);

    // Register dependencies
    _getIt.registerSingleton<NetworkChecker>(mockNetworkChecker);
    _getIt.registerSingleton<LoadingManager>(mockLoadingManager);
    _getIt.registerSingleton<WeatherBloc>(weatherBloc);

    // Provide dummy values for Either types
    registerDummyValues();

    return WeatherTestSetup(weatherBloc, mockWeatherRepository,
        mockNetworkChecker, mockLoadingManager);
  }

  /// Reset GetIt instance between tests
  static void resetGetIt() {
    // Reset all registered services
    if (_getIt.isRegistered<LocationBloc>()) {
      _getIt.unregister<LocationBloc>();
    }

    if (_getIt.isRegistered<WeatherBloc>()) {
      _getIt.unregister<WeatherBloc>();
    }

    if (_getIt.isRegistered<NetworkChecker>()) {
      _getIt.unregister<NetworkChecker>();
    }

    if (_getIt.isRegistered<LoadingManager>()) {
      _getIt.unregister<LoadingManager>();
    }
  }
}
