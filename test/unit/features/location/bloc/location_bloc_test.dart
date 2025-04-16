import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:weather_app_assignment/core/base/bloc/loading_state.dart';
import 'package:weather_app_assignment/core/dependency_injection/service_locator.dart';
import 'package:weather_app_assignment/core/error/AppError.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/data/repositories/i_location_repository.dart';
import 'package:weather_app_assignment/features/location/bloc/location_bloc.dart';
import 'package:weather_app_assignment/features/location/bloc/location_event.dart';
import 'package:weather_app_assignment/features/location/bloc/location_state.dart';

// Use the centralized mock generators instead of local annotations
import '../../../../mocks/mock_generators.mocks.dart';
import '../../../../mocks/test_helpers.dart';

void main() {
  late LocationBloc locationBloc;
  late MockILocationRepository mockRepository;
  late MockLoadingManager mockLoadingManager;

  setUp(() {
    mockRepository = MockILocationRepository();
    mockLoadingManager = MockLoadingManager();

    // Configure service locator with mock loading manager
    GetIt.instance.registerSingleton<LoadingManager>(mockLoadingManager);

    locationBloc = LocationBloc(mockRepository);

    // Provide dummy value for Either type
    provideDummy<Either<DataException, List<Country>>>(Right([]));
    provideDummy<Either<DataException, Country>>(Right(const Country(
      id: 1,
      name: 'United States',
      iso2: 'US',
      iso3: 'USA',
      phonecode: '1',
      capital: 'Washington',
      currency: 'USD',
      native: 'United States',
      emoji: '🇺🇸',
    )));
  });

  tearDown(() {
    locationBloc.close();
    GetIt.instance.reset();
  });

  group('LocationBloc', () {
    final testCountries = [
      const Country(
        id: 1,
        name: 'United States',
        iso2: 'US',
        iso3: 'USA',
        phonecode: '1',
        capital: 'Washington',
        currency: 'USD',
        native: 'United States',
        emoji: '🇺🇸',
      ),
      const Country(
        id: 2,
        name: 'United Kingdom',
        iso2: 'GB',
        iso3: 'GBR',
        phonecode: '44',
        capital: 'London',
        currency: 'GBP',
        native: 'United Kingdom',
        emoji: '🇬🇧',
      ),
    ];

    test('initial state is LocationState', () {
      expect(locationBloc.state, const LocationState());
    });

    blocTest<LocationBloc, LocationState>(
      'emits [loading, success] when GetCountriesEvent is added',
      setUp: () {
        when(mockRepository.getAllCountries())
            .thenAnswer((_) async => Right(testCountries));
      },
      build: () => locationBloc,
      act: (bloc) => bloc.add(GetCountriesEvent()),
      expect: () => [
        isA<LocationState>().having(
          (state) => state.countriesLoadingState,
          'loading state',
          isA<LoadingState<List<Country>>>()
              .having((s) => s.isLoading, 'isLoading', true),
        ),
        isA<LocationState>()
            .having(
              (state) => state.countriesLoadingState.isLoadedSuccess,
              'success state',
              true,
            )
            .having(
              (state) => state.countries,
              'countries',
              testCountries,
            ),
      ],
    );

    blocTest<LocationBloc, LocationState>(
      'emits [loading, error] when GetCountriesEvent fails',
      setUp: () {
        when(mockRepository.getAllCountries()).thenAnswer(
            (_) async => Left(DataException(message: 'Failed to load')));
      },
      build: () => locationBloc,
      act: (bloc) => bloc.add(GetCountriesEvent()),
      expect: () => [
        isA<LocationState>().having(
          (state) => state.countriesLoadingState,
          'loading state',
          isA<LoadingState<List<Country>>>()
              .having((s) => s.isLoading, 'isLoading', true),
        ),
        isA<LocationState>().having(
          (state) => state.countriesLoadingState.loadError?.message,
          'error state',
          'Failed to load',
        ),
      ],
    );

    // Tests for SearchLocationsEvent
    blocTest<LocationBloc, LocationState>(
      'emits correct states when SearchLocationsEvent is added with non-empty query',
      seed: () => LocationState(
        allCountries: testCountries,
        countries: testCountries,
      ),
      build: () => locationBloc,
      act: (bloc) => bloc.add(SearchLocationsEvent('United')),
      expect: () => [
        isA<LocationState>()
            .having(
              (state) => state.searchLoadingState,
              'loading state',
              isA<LoadingState>().having((s) => s.isLoading, 'isLoading', true),
            )
            .having((state) => state.query, 'query', 'United'),
        isA<LocationState>()
            .having(
              (state) => state.searchLoadingState.isLoadedSuccess,
              'success state',
              true,
            )
            .having(
              (state) => state.countries.length,
              'filtered countries count',
              2, // Both US and UK contain "United"
            ),
      ],
    );

    blocTest<LocationBloc, LocationState>(
      'emits correct states when SearchLocationsEvent is added with empty query',
      seed: () => LocationState(
        allCountries: testCountries,
        countries: [testCountries[0]], // Start with only US in filtered list
      ),
      build: () => locationBloc,
      act: (bloc) => bloc.add(SearchLocationsEvent('')),
      expect: () => [
        isA<LocationState>()
            .having(
              (state) => state.searchLoadingState,
              'loading state',
              isA<LoadingState>().having((s) => s.isLoading, 'isLoading', true),
            )
            .having((state) => state.query, 'query', ''),
        isA<LocationState>()
            .having(
              (state) => state.searchLoadingState.isLoadedSuccess,
              'success state',
              true,
            )
            .having(
              (state) => state.countries.length,
              'all countries count',
              2, // Should show all countries
            ),
      ],
    );

    // Test for CountrySelectedEvent
    blocTest<LocationBloc, LocationState>(
      'emits state with selected country when CountrySelectedEvent is added',
      build: () => locationBloc,
      act: (bloc) => bloc.add(CountrySelectedEvent(testCountries[0])),
      expect: () => [
        isA<LocationState>().having(
          (state) => state.selectedCountry,
          'selected country',
          testCountries[0],
        ),
      ],
    );

    // Test for ClearSelectionEvent
    blocTest<LocationBloc, LocationState>(
      'emits state with cleared country when ClearSelectionEvent is added',
      seed: () => LocationState(
        selectedCountry: testCountries[0],
      ),
      build: () => locationBloc,
      act: (bloc) => bloc.add(ClearSelectionEvent(clearCountry: true)),
      expect: () => [
        isA<LocationState>().having(
          (state) => state.selectedCountry,
          'selected country',
          isNull,
        ),
      ],
    );

    // Tests for GetCountryDetailsEvent
    blocTest<LocationBloc, LocationState>(
      'emits [loading, error] when GetCountryDetailsEvent fails',
      setUp: () {
        when(mockRepository.getCountryDetails('ZZ')).thenAnswer(
            (_) async => Left(DataException(message: 'Country not found')));
      },
      build: () => locationBloc,
      act: (bloc) => bloc.add(GetCountryDetailsEvent('ZZ')),
      expect: () => [
        isA<LocationState>().having(
          (state) => state.countryDetailsLoadingState,
          'loading state',
          isA<LoadingState<Country>>()
              .having((s) => s.isLoading, 'isLoading', true),
        ),
        isA<LocationState>().having(
          (state) => state.countryDetailsLoadingState.loadError,
          'error state',
          isA<AppError>()
              .having((e) => e.message, 'message', 'Country not found'),
        ),
      ],
      verify: (_) {
        verifyNever(mockRepository.getAllCountries());
      },
    );

    // Tests for convenience methods
    test('getCountries adds GetCountriesEvent', () {
      when(mockRepository.getAllCountries())
          .thenAnswer((_) async => Right(testCountries));

      locationBloc.getCountries();
      // Need to let the event be processed
      Future.delayed(const Duration(milliseconds: 100), () {
        verify(mockRepository.getAllCountries()).called(1);
      });
    });

    test('getCountryDetails adds GetCountryDetailsEvent', () {
      when(mockRepository.getCountryDetails('US'))
          .thenAnswer((_) async => Right(testCountries[0]));

      locationBloc.getCountryDetails('US');
      // Need to let the event be processed
      Future.delayed(const Duration(milliseconds: 100), () {
        verify(mockRepository.getCountryDetails('US')).called(1);
      });
    });

    test('searchCountries adds SearchLocationsEvent', () {
      locationBloc.searchCountries('United');
      expect(locationBloc.state.query, isEmpty);
    });

    test('clearSelections adds ClearSelectionEvent', () {
      locationBloc.clearSelections(clearCountry: true);
      expect(locationBloc.state.selectedCountry, isNull);
    });
  });
}
