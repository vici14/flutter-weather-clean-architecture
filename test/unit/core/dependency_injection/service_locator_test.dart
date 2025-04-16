import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app_assignment/core/dependency_injection/service_locator.dart';
import 'package:weather_app_assignment/core/services/firebase_manager.dart';
import 'package:weather_app_assignment/core/services/network_checker.dart';
import 'package:weather_app_assignment/data/service_manager.dart';
import 'package:weather_app_assignment/features/location/bloc/location_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:weather_app_assignment/data/repositories/i_location_repository.dart';
import 'package:weather_app_assignment/data/repositories/i_weather_repository.dart';

import 'service_locator_test.mocks.dart';

@GenerateMocks([
  NetworkChecker,
  FirebaseManager,
  ServiceManager,
  InternetConnection,
  LocationBloc,
  ILocationRepository,
  IWeatherRepository,
])
void main() {
  final GetIt getIt = GetIt.instance;
  late MockNetworkChecker mockNetworkChecker;
  late MockFirebaseManager mockFirebaseManager;
  late MockServiceManager mockServiceManager;
  late MockInternetConnection mockInternetConnection;
  late MockLocationBloc mockLocationBloc;
  late MockILocationRepository mockLocationRepository;
  late MockIWeatherRepository mockWeatherRepository;

  setUp(() {
    // Reset GetIt before each test
    GetIt.I.reset();

    // Reset ServiceLocator flags
    resetServiceLocatorFlags();

    mockNetworkChecker = MockNetworkChecker();
    mockFirebaseManager = MockFirebaseManager();
    mockServiceManager = MockServiceManager();
    mockInternetConnection = MockInternetConnection();
    mockLocationBloc = MockLocationBloc();
    mockLocationRepository = MockILocationRepository();
    mockWeatherRepository = MockIWeatherRepository();

    // Register mocks
    getIt.registerSingleton<NetworkChecker>(mockNetworkChecker);
    getIt.registerSingleton<FirebaseManager>(mockFirebaseManager);
    getIt.registerSingleton<ServiceManager>(mockServiceManager);
    getIt.registerSingleton<InternetConnection>(mockInternetConnection);
    getIt.registerSingleton<ILocationRepository>(mockLocationRepository);
    getIt.registerSingleton<IWeatherRepository>(mockWeatherRepository);
    getIt.registerSingleton<LocationBloc>(mockLocationBloc);
  });

  group('Service Locator', () {
    test(
        'setupServiceLocator returns true when services initialized successfully',
        () async {
      // Setup mocks
      when(mockNetworkChecker.checkConnection()).thenAnswer((_) async => true);
      when(mockFirebaseManager.initialize()).thenAnswer((_) async {});
      when(mockFirebaseManager.getLocationApiKey())
          .thenAnswer((_) async => 'location_api_key');
      when(mockFirebaseManager.getWeatherApiKey())
          .thenAnswer((_) async => 'weather_api_key');
      when(mockFirebaseManager.isInitialized).thenReturn(true);

      final result = await setupServiceLocator();

      expect(result, isTrue);
      verify(mockNetworkChecker.checkConnection()).called(1);
    });

    test('setupServiceLocator returns false when network check fails',
        () async {
      // Setup mocks
      when(mockNetworkChecker.checkConnection()).thenAnswer((_) async => false);

      final result = await setupServiceLocator();

      expect(result, isFalse);
      verify(mockNetworkChecker.checkConnection()).called(1);
    });

    test('retryServiceInitialization returns false when network check fails',
        () async {
      // Setup mocks
      when(mockNetworkChecker.checkConnection()).thenAnswer((_) async => false);

      final result = await retryServiceInitialization();

      expect(result, isFalse);
      verify(mockNetworkChecker.checkConnection()).called(1);
    });

    test(
        'retryServiceInitialization returns true and initializes services when network check succeeds',
        () async {
      // Setup mocks
      when(mockNetworkChecker.checkConnection()).thenAnswer((_) async => true);
      when(mockFirebaseManager.isInitialized).thenReturn(false);
      when(mockFirebaseManager.retry()).thenAnswer((_) async => true);
      when(mockFirebaseManager.getLocationApiKey())
          .thenAnswer((_) async => 'location_api_key');
      when(mockFirebaseManager.getWeatherApiKey())
          .thenAnswer((_) async => 'weather_api_key');

      final result = await retryServiceInitialization();

      expect(result, isTrue);
      verify(mockNetworkChecker.checkConnection()).called(1);
      verify(mockFirebaseManager.retry()).called(1);
      verify(mockLocationBloc.getCountries()).called(1);
    });
  });
}
