import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:weather_app_assignment/data/repositories/i_weather_repository.dart';
import 'package:weather_app_assignment/data/repositories/weather_repository.dart';
import 'package:weather_app_assignment/data/repositories/i_location_repository.dart';
import 'package:weather_app_assignment/data/repositories/location_repository.dart';
import 'package:weather_app_assignment/features/weather/bloc/weather_bloc.dart';
import 'package:weather_app_assignment/features/location/bloc/location_bloc.dart';
import 'package:weather_app_assignment/data/service_manager.dart';
import 'package:weather_app_assignment/core/services/firebase_manager.dart';
import 'package:weather_app_assignment/core/services/secure_storage.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';
import 'package:weather_app_assignment/core/services/network_checker.dart';
import 'package:weather_app_assignment/routes/app_routes.dart';

final getIt = GetIt.instance;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool _isInitializingServices = false;
bool _servicesInitialized = false;

Future<bool> setupServiceLocator() async {
  if (_servicesInitialized) return true;
  if (_isInitializingServices) return false;

  _isInitializingServices = true;

  try {
    // Register core services first
    // Services - check if already registered
    if (!getIt.isRegistered<SecureStorage>()) {
      getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());
    }

    if (!getIt.isRegistered<LoadingManager>()) {
      getIt.registerLazySingleton<LoadingManager>(
          () => LoadingManager(navigatorKey));
    }

    // Register Network services
    if (!getIt.isRegistered<InternetConnection>()) {
      getIt.registerLazySingleton(() => InternetConnection());
    }

    if (!getIt.isRegistered<NetworkChecker>()) {
      getIt.registerLazySingleton<NetworkChecker>(
          () => NetworkChecker(getIt<InternetConnection>()));
    }

    // Register Firebase - check if already registered
    if (!getIt.isRegistered<FirebaseManager>()) {
      getIt.registerLazySingleton<FirebaseManager>(() => FirebaseManager());
      // Set SecureStorage only during initial registration
      getIt<FirebaseManager>().setSecureStorage(getIt<SecureStorage>());
    }

    // Check connectivity early
    bool hasConnection = await getIt<NetworkChecker>().checkConnection();
    if (!hasConnection) {
      print('No internet connection detected during initialization');
      _isInitializingServices = false;
      return false;
    }

    // Try to initialize Firebase with timeout
    try {
      await getIt<FirebaseManager>().initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Firebase initialization timed out');
        },
      );
    } catch (e) {
      print('Firebase initialization error: $e');
      // If it's a network error, return false to show network error screen
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('network') ||
          e.toString().contains('remote_config')) {
        _isInitializingServices = false;
        return false;
      }
      // Otherwise continue with app initialization
    }

    // ServiceManager with API keys from SecureStorage
    if (!getIt.isRegistered<ServiceManager>()) {
      getIt.registerLazySingleton<ServiceManager>(() => ServiceManager());
    }

    // Initialize ServiceManager (may use empty keys if Firebase failed)
    getIt<ServiceManager>().initialize(
      locationApiKey: await getIt<FirebaseManager>().getLocationApiKey(),
      weatherApiKey: await getIt<FirebaseManager>().getWeatherApiKey(),
    );

    // Repositories
    if (!getIt.isRegistered<IWeatherRepository>()) {
      getIt.registerLazySingleton<IWeatherRepository>(
        () => WeatherRepository(getIt<ServiceManager>()),
      );
    }

    if (!getIt.isRegistered<ILocationRepository>()) {
      getIt.registerLazySingleton<ILocationRepository>(
        () => LocationRepository(getIt<ServiceManager>()),
      );
    }

    // Blocs
    if (!getIt.isRegistered<LocationBloc>()) {
      getIt.registerLazySingleton<LocationBloc>(
        () => LocationBloc(getIt<ILocationRepository>()),
      );
    }

    // Fetch countries data
    getIt<LocationBloc>().getCountries();

    _servicesInitialized = true;
    _isInitializingServices = false;
    return true;
  } catch (e) {
    print('Error during service locator setup: $e');
    _isInitializingServices = false;

    // Return false to show the network error screen
    return false;
  }
}

Future<bool> retryServiceInitialization() async {
  if (_servicesInitialized) return true;

  try {
    bool hasConnection = await getIt<NetworkChecker>().checkConnection();
    if (!hasConnection) return false;

    // Retry Firebase initialization if needed
    if (!getIt<FirebaseManager>().isInitialized) {
      await getIt<FirebaseManager>().retry();

      // Update ServiceManager with new API keys if Firebase succeeded
      if (getIt.isRegistered<ServiceManager>()) {
        getIt<ServiceManager>().initialize(
          locationApiKey: await getIt<FirebaseManager>().getLocationApiKey(),
          weatherApiKey: await getIt<FirebaseManager>().getWeatherApiKey(),
        );
      }
    }

    // Try to fetch countries if not already done and if LocationBloc is registered
    if (getIt.isRegistered<LocationBloc>()) {
      getIt<LocationBloc>().getCountries();
    }

    _servicesInitialized = true;
    return true;
  } catch (e) {
    print('Error during service initialization retry: $e');
    return false;
  }
}
