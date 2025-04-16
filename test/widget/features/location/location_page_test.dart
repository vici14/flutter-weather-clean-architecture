import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:weather_app_assignment/core/base/bloc/loading_state.dart';
import 'package:weather_app_assignment/core/error/AppError.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';
import 'package:weather_app_assignment/core/services/network_checker.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/features/location/bloc/location_bloc.dart';
import 'package:weather_app_assignment/features/location/bloc/location_state.dart';
import 'package:weather_app_assignment/features/location/pages/home_page.dart';
import 'package:weather_app_assignment/features/location/widgets/country_list_widget.dart';
import '../../../mocks/mock_generators.mocks.dart';
import '../../../test_helpers/test_setup.dart';
import '../../../test_helpers/dummy_values.dart';

void main() {
  late MockILocationRepository mockLocationRepository;
  late LocationBloc locationBloc;
  late MockNetworkChecker mockNetworkChecker;
  late MockLoadingManager mockLoadingManager;
  final getIt = GetIt.instance;

  setUp(() {
    // Initialize the binding for widget tests
    TestSetup.setupWidgetTest();

    // Use improved test setup helper
    final setup = TestSetup.setupLocationTest();
    locationBloc = setup.bloc;
    mockLocationRepository = setup.repository;
    mockNetworkChecker = setup.networkChecker;
    mockLoadingManager = setup.loadingManager;

    // Register dummy values
    registerDummyValues();
  });

  tearDown(() {
    locationBloc.close();
    TestSetup.resetGetIt();
  });

  final mockCountries = [
    const Country(
      id: 1,
      name: 'United States',
      iso2: 'US',
      capital: 'Washington, D.C.',
      region: 'Americas',
      latitude: '38.8951',
      longitude: '-77.0364',
    ),
    const Country(
      id: 2,
      name: 'United Kingdom',
      iso2: 'GB',
      capital: 'London',
      region: 'Europe',
      latitude: '51.5074',
      longitude: '-0.1278',
    ),
  ];

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          // Ensure GetIt is accessible in tests
          Provider.value(value: getIt),
          BlocProvider<LocationBloc>.value(value: locationBloc),
          Provider<NetworkChecker>.value(value: mockNetworkChecker),
          Provider<LoadingManager>.value(value: mockLoadingManager),
        ],
        child: const HomePage(),
      ),
    );
  }

  testWidgets('displays loading indicator when fetching countries',
      (WidgetTester tester) async {
    // Setup repository response
    when(mockLocationRepository.getAllCountries())
        .thenAnswer((_) async => Right<DataException, List<Country>>([]));

    // Set loading state
    locationBloc.emit(const LocationState(
      countriesLoadingState: LoadingState(isLoading: true),
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 100));

    // Look for CircularProgressIndicator in the widget tree
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays countries when fetch succeeds',
      (WidgetTester tester) async {
    // Mock repository response
    when(mockLocationRepository.getAllCountries()).thenAnswer(
        (_) async => Right<DataException, List<Country>>(mockCountries));

    // Emit loaded state
    locationBloc.emit(LocationState(
      countriesLoadingState: LoadingState<List<Country>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: mockCountries,
      ),
      countries: mockCountries,
      allCountries: mockCountries,
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 100));

    // First verify the CountryListWidget is rendered
    expect(find.byType(CountryListWidget), findsOneWidget);

    // Then check for country names
    expect(find.text('United States'), findsOneWidget);
    expect(find.text('United Kingdom'), findsOneWidget);
  });

  testWidgets('displays error message when fetch fails',
      (WidgetTester tester) async {
    // Setup repository to return an error
    final error = DataException(message: 'Failed to fetch countries');
    when(mockLocationRepository.getAllCountries())
        .thenAnswer((_) async => Left<DataException, List<Country>>(error));

    // Emit error state
    locationBloc.emit(LocationState(
      countriesLoadingState: LoadingState<List<Country>>.error(
        AppError(message: 'Failed to fetch countries'),
      ),
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 100));

    // Look for error message
    expect(find.textContaining('Failed to fetch'), findsOneWidget);
  });

  testWidgets('filters countries when searching', (WidgetTester tester) async {
    // Setup initial state with both countries
    locationBloc.emit(LocationState(
      countriesLoadingState: LoadingState<List<Country>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: mockCountries,
      ),
      countries: mockCountries,
      allCountries: mockCountries,
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 100));

    // Verify both countries show up initially
    expect(find.text('United States'), findsOneWidget);
    expect(find.text('United Kingdom'), findsOneWidget);

    // Now filter only to United States
    final filteredList = [mockCountries[0]]; // Only United States

    // Emit new state with filtered list
    locationBloc.emit(LocationState(
      countriesLoadingState: LoadingState<List<Country>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: mockCountries,
      ),
      query: 'States',
      countries: filteredList,
      allCountries: mockCountries,
    ));

    await tester.pump(const Duration(milliseconds: 100));

    // Pump a few more times to ensure the UI updates
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Now the United Kingdom should no longer be visible, only United States should remain
    expect(find.text('United States'), findsOneWidget);

    // Check United Kingdom is not shown using direct text finding approach
    expect(find.text('United Kingdom', skipOffstage: false), findsNothing);
  });

  testWidgets('selects country on tap', (WidgetTester tester) async {
    // Setup country selection response
    when(mockLocationRepository.getCountryDetails('US')).thenAnswer(
        (_) async => Right<DataException, Country>(mockCountries[0]));

    // Emit loaded state
    locationBloc.emit(LocationState(
      countriesLoadingState: LoadingState<List<Country>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: mockCountries,
      ),
      countries: mockCountries,
      allCountries: mockCountries,
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 100));

    // Find and tap on a specific country
    final countryFinder = find.text('United States');
    expect(countryFinder, findsOneWidget);
    await tester.tap(countryFinder);
    await tester.pump(const Duration(milliseconds: 100));

    // Verify the country details was requested
    verify(mockLocationRepository.getCountryDetails('US')).called(1);
  });
}
