import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:weather_app_assignment/core/error/AppError.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';

import '../../../../../lib/core/base/bloc/loading_state.dart';
import '../../../../../lib/core/error/app_error.dart';
import '../../../../../lib/data/models/country.dart';
import '../../../../../lib/features/location/bloc/location_bloc.dart';
import '../../../../../lib/features/location/bloc/location_state.dart';
import '../../../../../lib/features/location/widgets/country_list_widget.dart';
import '../../../../mocks/mock_location_repository.dart';
import '../../../../mocks/repositories/location_repository_mock.dart';

void main() {
  late MockLocationRepository mockLocationRepository;
  late LocationBloc locationBloc;

  setUp(() {
    mockLocationRepository = MockLocationRepository();
    locationBloc = LocationBloc(mockLocationRepository);
  });

  tearDown(() {
    locationBloc.close();
  });

  final mockCountries = [
    Country(
      id: 1,
      name: 'United States',
      iso2: 'US',
      capital: 'Washington, D.C.',
      region: 'Americas',
      latitude: '38.8951',
      longitude: '-77.0364',
    ),
    Country(
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
      home: Scaffold(
        body: BlocProvider<LocationBloc>.value(
          value: locationBloc,
          child: const CountryListWidget(),
        ),
      ),
    );
  }

  testWidgets('displays loading indicator when loading countries',
      (WidgetTester tester) async {
    when(mockLocationRepository.getAllCountries())
        .thenAnswer((_) async => right(mockCountries));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays countries when loaded', (WidgetTester tester) async {
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

    expect(find.text('United States'), findsOneWidget);
    expect(find.text('United Kingdom'), findsOneWidget);
    expect(find.text('Washington, D.C.'), findsOneWidget);
    expect(find.text('London'), findsOneWidget);
  });

  testWidgets('displays error message when loading fails',
      (WidgetTester tester) async {
    locationBloc.emit(LocationState(
      countriesLoadingState: LoadingState.error(
        AppError(message: 'Failed to load countries'),
      ),
    ));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Failed to load countries'), findsOneWidget);
  });

  testWidgets('displays search results', (WidgetTester tester) async {
    locationBloc.emit(LocationState(
      countriesLoadingState: LoadingState<List<Country>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: mockCountries,
      ),
      countries: [mockCountries[0]], // Only US as search result
      allCountries: mockCountries,
      query: 'States',
      searchLoadingState: LoadingState<List<Country>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: [mockCountries[0]],
      ),
    ));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Search results for "States"'), findsOneWidget);
    expect(find.text('United States'), findsOneWidget);
    expect(find.text('United Kingdom'), findsNothing);
  });

  testWidgets('displays no results message when search has no matches',
      (WidgetTester tester) async {
    locationBloc.emit(LocationState(
      countriesLoadingState: LoadingState<List<Country>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: mockCountries,
      ),
      countries: [], // Empty search results
      allCountries: mockCountries,
      query: 'XYZ',
      searchLoadingState: LoadingState<List<Country>>(
        isLoading: false,
        isLoadedSuccess: true,
        value: [],
      ),
    ));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('No countries found for "XYZ"'), findsOneWidget);
  });
}
