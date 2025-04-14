import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:weather_app_assignment/core/base/bloc/loading_state.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/features/location/bloc/location_bloc.dart';
import 'package:weather_app_assignment/features/location/bloc/location_event.dart';
import 'package:weather_app_assignment/features/location/bloc/location_state.dart';
import 'package:weather_app_assignment/features/location/pages/home_page.dart';
import 'package:weather_app_assignment/data/repositories/i_location_repository.dart';
import '../../../mocks/mock_location_repository.dart';
import '../../../mocks/repositories/location_repository_mock.mocks.dart';

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
      home: BlocProvider<LocationBloc>(
        create: (context) => locationBloc,
        child: const HomePage(),
      ),
    );
  }

  testWidgets('displays loading indicator when fetching countries',
      (WidgetTester tester) async {
    when(mockLocationRepository.getAllCountries())
        .thenAnswer((_) async => Right(mockCountries));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays countries when fetch succeeds',
      (WidgetTester tester) async {
    when(mockLocationRepository.getAllCountries())
        .thenAnswer((_) async => Right(mockCountries));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('United States'), findsOneWidget);
    expect(find.text('United Kingdom'), findsOneWidget);
  });

  testWidgets('displays error message when fetch fails',
      (WidgetTester tester) async {
    when(mockLocationRepository.getAllCountries()).thenAnswer(
        (_) async => Left(DataException(message: 'Failed to fetch countries')));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Failed to fetch countries'), findsOneWidget);
  });

  testWidgets('filters countries when searching', (WidgetTester tester) async {
    when(mockLocationRepository.getAllCountries())
        .thenAnswer((_) async => Right(mockCountries));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'United');
    await tester.pumpAndSettle();

    expect(find.text('United States'), findsOneWidget);
    expect(find.text('United Kingdom'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'States');
    await tester.pumpAndSettle();

    expect(find.text('United States'), findsOneWidget);
    expect(find.text('United Kingdom'), findsNothing);
  });

  testWidgets('selects country on tap', (WidgetTester tester) async {
    when(mockLocationRepository.getAllCountries())
        .thenAnswer((_) async => Right(mockCountries));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('United States'));
    await tester.pumpAndSettle();

    verify(mockLocationRepository.getCountryDetails('US')).called(1);
  });
}
