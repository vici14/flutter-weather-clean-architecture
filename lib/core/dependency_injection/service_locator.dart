import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../data/repositories/i_weather_repository.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/repositories/i_location_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../../features/weather/bloc/weather_bloc.dart';
import '../../features/location/bloc/location_bloc.dart';
import '../../data/service_manager.dart';
import '../../core/services/firebase_manager.dart';
import '../../core/services/secure_storage.dart';
import '../../core/services/loading_manager.dart';
import '../../core/services/network_checker.dart';
import '../../routes/app_routes.dart';

final getIt = GetIt.instance;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> setupServiceLocator() async {
     // Register NetworkChecker
    getIt.registerLazySingleton(() => InternetConnection());
    getIt.registerLazySingleton<NetworkChecker>(
        () => NetworkChecker(getIt<InternetConnection>()));
         // Initial network check
     // Services
    getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());
    getIt.registerLazySingleton<LoadingManager>(
        () => LoadingManager(navigatorKey));



    getIt.registerLazySingleton<FirebaseManager>(() => FirebaseManager());
    getIt<FirebaseManager>().setSecureStorage(getIt<SecureStorage>());
    await getIt<FirebaseManager>().initialize();

    // ServiceManager with API keys from SecureStorage
    getIt.registerLazySingleton<ServiceManager>(() => ServiceManager());
    getIt<ServiceManager>().initialize(
      locationApiKey: await getIt<FirebaseManager>().getLocationApiKey(),
      weatherApiKey: await getIt<FirebaseManager>().getWeatherApiKey(),
    );

    // Repositories
    getIt.registerLazySingleton<IWeatherRepository>(
      () => WeatherRepository(getIt<ServiceManager>()),
    );

    getIt.registerLazySingleton<ILocationRepository>(
      () => LocationRepository(getIt<ServiceManager>()),
    );

    // Blocs
    getIt.registerLazySingleton<LocationBloc>(
      () => LocationBloc(getIt<ILocationRepository>()),
    );
    getIt<LocationBloc>().getCountries();

}
 