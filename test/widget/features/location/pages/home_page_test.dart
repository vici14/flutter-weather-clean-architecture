import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:weather_app_assignment/core/base/bloc/loading_state.dart';
import 'package:weather_app_assignment/core/error/AppError.dart';
import 'package:weather_app_assignment/core/error/app_error.dart';
import 'package:weather_app_assignment/core/services/network_checker.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/features/location/bloc/location_bloc.dart';
import 'package:weather_app_assignment/features/location/bloc/location_event.dart';
import 'package:weather_app_assignment/features/location/bloc/location_state.dart';
import 'package:weather_app_assignment/features/location/pages/home_page.dart';
import 'package:weather_app_assignment/core/dependency_injection/service_locator.dart';

@GenerateNiceMocks([MockSpec<LocationBloc>(), MockSpec<NetworkChecker>()])
import 'home_page_test.mocks.dart';

void main() {
  late MockLocationBloc mockLocationBloc;
  late MockNetworkChecker mockNetworkChecker;

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

  Widget createHomeScreen() {
    return MaterialApp(
      home: BlocProvider<LocationBloc>.value(
        value: mockLocationBloc,
        child: const HomePage(),
      ),
    );
  }

  setUp(() {
    mockLocationBloc = MockLocationBloc();
    mockNetworkChecker = MockNetworkChecker();

    // Setup default state
    when(mockLocationBloc.state).thenReturn(const LocationState());

    // Setup network checker
    when(mockNetworkChecker.connectionStatus)
        .thenAnswer((_) => Stream.value(true));

    // Register mock dependencies
    getIt.registerSingleton<NetworkChecker>(mockNetworkChecker);
    getIt.registerSingleton<LocationBloc>(mockLocationBloc);
  });

  tearDown(() {
    getIt.reset();
  });

  group('HomePage - Initial Load', () {
    testWidgets('renders loading indicator when loading countries',
        (WidgetTester tester) async {
      when(mockLocationBloc.state).thenReturn(LocationState(
        countriesLoadingState: LoadingState<List<Country>>.loading(),
      ));

      await tester.pumpWidget(createHomeScreen());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('renders country list when data is loaded',
        (WidgetTester tester) async {
      when(mockLocationBloc.state).thenReturn(LocationState(
        countriesLoadingState: LoadingState<List<Country>>(
          isLoading: false,
          isLoadedSuccess: true,
          value: testCountries,
        ),
        countries: testCountries,
        allCountries: testCountries,
        query: 'United States',
      ));

      await tester.pumpWidget(createHomeScreen());

      expect(find.text('United States'), findsOneWidget);
      expect(find.text('United Kingdom'), findsOneWidget);
    });

    testWidgets('shows error message when loading fails',
        (WidgetTester tester) async {
      when(mockLocationBloc.state).thenReturn(LocationState(
        countriesLoadingState: LoadingState<List<Country>>.error(
          AppError(message: 'Failed to load countries'),
        ),
      ));

      await tester.pumpWidget(createHomeScreen());

      expect(find.text('Failed to load countries'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });
  });

  group('HomePage - Search Functionality', () {
    testWidgets('triggers search when text is entered',
        (WidgetTester tester) async {
      when(mockLocationBloc.state).thenReturn(LocationState(
        countriesLoadingState: LoadingState<List<Country>>(
          isLoading: false,
          isLoadedSuccess: true,
          value: testCountries,
        ),
        countries: testCountries,
        allCountries: testCountries,
        query: 'United States',
      ));

      await tester.pumpWidget(createHomeScreen());

      await tester.enterText(find.byType(TextField), 'United');
      await tester.pump(const Duration(milliseconds: 300));

      verify(mockLocationBloc.searchCountries('United')).called(1);
    });

    testWidgets('shows filtered results when search is active',
        (WidgetTester tester) async {
      final filteredCountries = [testCountries[0]];

      when(mockLocationBloc.state).thenReturn(LocationState(
        countriesLoadingState: LoadingState<List<Country>>(
          isLoading: false,
          isLoadedSuccess: true,
          value: testCountries,
        ),
        countries: filteredCountries,
        allCountries: testCountries,
        query: 'United States',
      ));

      await tester.pumpWidget(createHomeScreen());
      await tester.enterText(find.byType(TextField), 'United States');
      await tester.pump();

      expect(find.widgetWithText(Card, 'United States'), findsOneWidget);
      expect(find.widgetWithText(Card, 'United Kingdom'), findsNothing);
    });
  });

  group('HomePage - Scroll Behavior', () {
    testWidgets('shows pinned search bar when scrolled down',
        (WidgetTester tester) async {
      when(mockLocationBloc.state).thenReturn(LocationState(
        countriesLoadingState: LoadingState<List<Country>>(
          isLoading: false,
          isLoadedSuccess: true,
          value: testCountries,
        ),
        countries: testCountries,
        allCountries: testCountries,
        query: 'United States',
      ));

      await tester.pumpWidget(createHomeScreen());

      // Initial state - search bar should be visible but not pinned
      expect(find.byType(TextField), findsOneWidget);

      // Scroll down
      await tester.drag(find.byType(NestedScrollView), const Offset(0, -100));
      await tester.pump();
      await tester
          .pump(const Duration(milliseconds: 300)); // Animation duration

      // Should still find one search bar (now pinned)
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('HomePage - Network Connectivity', () {
    testWidgets('reloads data when network connection is restored',
        (WidgetTester tester) async {
      // Setup stream controller for network status
      final streamController = StreamController<bool>();
      when(mockNetworkChecker.connectionStatus)
          .thenAnswer((_) => streamController.stream);

      await tester.pumpWidget(createHomeScreen());

      // Simulate network restoration
      streamController.add(true);
      await tester.pump();

      verify(mockLocationBloc.getCountries()).called(1);

      // Cleanup
      await streamController.close();
    });
  });
}
