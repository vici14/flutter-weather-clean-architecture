import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';
import 'package:weather_app_assignment/core/services/network_checker.dart';
import 'package:weather_app_assignment/data/repositories/i_location_repository.dart';
import 'package:weather_app_assignment/features/location/bloc/location_bloc.dart';
import 'package:weather_app_assignment/features/location/bloc/location_event.dart';
import 'package:weather_app_assignment/features/location/widgets/country_list_widget.dart';
import '../../mocks/mock_loading_manager.dart';
import '../../mocks/mock_location_repository.dart';
import '../../mocks/mock_network_checker.dart';

void main() {
  late LocationBloc locationBloc;
  late MockLocationRepository mockRepository;
  late MockLoadingManager mockLoadingManager;
  late MockNetworkChecker mockNetworkChecker;

  setUp(() {
    mockRepository = MockLocationRepository();
    mockLoadingManager = MockLoadingManager();
    mockNetworkChecker = MockNetworkChecker();

    GetIt.I.registerSingleton<ILocationRepository>(mockRepository);
    GetIt.I.registerSingleton<LoadingManager>(mockLoadingManager);
    GetIt.I.registerSingleton<NetworkChecker>(mockNetworkChecker);

    locationBloc = LocationBloc(mockRepository);
  });

  tearDown(() {
    locationBloc.close();
    mockLoadingManager.dispose();
    mockNetworkChecker.dispose();
    GetIt.I.reset();
  });

  testWidgets('CountryListWidget should show loading indicator initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: locationBloc,
          child: const CountryListWidget(),
        ),
      ),
    );

    // Initially should show loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('CountryListWidget should show countries when loaded',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: locationBloc,
          child: const CountryListWidget(),
        ),
      ),
    );

    // Trigger loading of countries
    locationBloc.add(GetCountriesEvent());
    await tester.pumpAndSettle();

    // Should show country items
    expect(find.text('United States'), findsOneWidget);
    expect(find.text('United Kingdom'), findsOneWidget);
  });

  testWidgets('CountryListWidget should handle country selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: locationBloc,
          child: const CountryListWidget(),
        ),
      ),
    );

    // Load countries
    locationBloc.add(GetCountriesEvent());
    await tester.pumpAndSettle();

    // Tap on a country
    await tester.tap(find.text('United States'));
    await tester.pumpAndSettle();

    // Verify that the country is selected in the bloc state
    expect(locationBloc.state.selectedCountry?.name, equals('United States'));
  });

  testWidgets('CountryListWidget should show error message on failure',
      (WidgetTester tester) async {
    // Create a new mock repository that returns error
    mockRepository = MockLocationRepository(shouldFail: true);
    GetIt.I.unregister<ILocationRepository>();
    GetIt.I.registerSingleton<ILocationRepository>(mockRepository);
    locationBloc = LocationBloc(mockRepository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: locationBloc,
          child: const CountryListWidget(),
        ),
      ),
    );

    // Trigger loading of countries
    locationBloc.add(GetCountriesEvent());
    await tester.pumpAndSettle();

    // Should show error message
    expect(find.text('Failed to load countries'), findsOneWidget);
  });
}
