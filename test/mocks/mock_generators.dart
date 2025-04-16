import 'package:mockito/annotations.dart';
import 'package:fpdart/fpdart.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';
import 'package:weather_app_assignment/core/services/network_checker.dart';
import 'package:weather_app_assignment/data/repositories/i_location_repository.dart';
import 'package:weather_app_assignment/data/repositories/i_weather_repository.dart';
import 'package:weather_app_assignment/data/services/location_service.dart';
import 'package:weather_app_assignment/features/location/bloc/location_bloc.dart';
import 'package:weather_app_assignment/features/weather/bloc/weather_bloc.dart';
import 'package:weather_app_assignment/data/api_client.dart';
import 'package:weather_app_assignment/data/service_manager.dart';
import 'package:weather_app_assignment/data/services/weather_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:weather_app_assignment/core/services/secure_storage.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/data/models/weather_forecast.dart';
import 'package:flutter/material.dart'; // Added for NavigatorState and OverlayState

// Export the generated mocks file so it can be imported with a single import
export 'mock_generators.mocks.dart';

// Helper functions to create Either instances
Either<L, R> left<L, R>(L value) => Either.left(value);
Either<L, R> right<L, R>(R value) => Either.right(value);

@GenerateNiceMocks([
  // Repositories
  MockSpec<ILocationRepository>(),
  MockSpec<IWeatherRepository>(),

  // Services
  MockSpec<LoadingManager>(),
  MockSpec<NetworkChecker>(),
  MockSpec<ApiClient>(),
  MockSpec<ServiceManager>(),
  MockSpec<WeatherService>(),
  MockSpec<LocationService>(),
  MockSpec<FlutterSecureStorage>(),
  MockSpec<SecureStorage>(),
  MockSpec<Dio>(),

  // Blocs
  MockSpec<LocationBloc>(),
  MockSpec<WeatherBloc>(),

  // Flutter Widgets & Navigation
  MockSpec<NavigatorState>(),
  MockSpec<OverlayState>(),
])
void main() {}
