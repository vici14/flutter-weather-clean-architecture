import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';
import 'package:weather_app_assignment/core/services/network_checker.dart';
import 'package:weather_app_assignment/data/repositories/i_location_repository.dart';
import 'package:weather_app_assignment/features/location/bloc/location_bloc.dart';
import 'package:weather_app_assignment/features/location/pages/home_page.dart';
import '../../mocks/mock_loading_manager.dart';
import '../../mocks/mock_location_repository.dart';
import '../../mocks/mock_network_checker.dart';

void main() {
  late MockNetworkChecker mockNetworkChecker;
  late LocationBloc locationBloc;
  late MockLocationRepository mockRepository;
  late MockLoadingManager mockLoadingManager;

  setUp(() {
    mockNetworkChecker = MockNetworkChecker();
    mockNetworkChecker.initialize();
    mockRepository = MockLocationRepository();
    mockLoadingManager = MockLoadingManager();
    locationBloc = LocationBloc(mockRepository);

    GetIt.I.registerSingleton<ILocationRepository>(mockRepository);
    GetIt.I.registerSingleton<LoadingManager>(mockLoadingManager);
    GetIt.I.registerSingleton<NetworkChecker>(mockNetworkChecker);
  });

  tearDown(() {
    GetIt.I.unregister<NetworkChecker>();
    locationBloc.close();
    mockLoadingManager.dispose();
  });

  testWidgets('HomePage should render search field and list',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: locationBloc,
          child: const HomePage(),
        ),
      ),
    );

    // Verify that search field is rendered
    expect(find.byType(TextField), findsOneWidget);

    // Verify that the list is rendered
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('Search field should update on input',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: locationBloc,
          child: const HomePage(),
        ),
      ),
    );

    // Enter text in search field
    await tester.enterText(find.byType(TextField), 'United');
    await tester.pump();

    // Verify that the text was entered
    expect(find.text('United'), findsOneWidget);
  });

  testWidgets('Scroll behavior should work correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: locationBloc,
          child: const HomePage(),
        ),
      ),
    );

    // Initial state - search field should be visible
    expect(find.byType(TextField), findsOneWidget);

    // Scroll down
    await tester.drag(find.byType(NestedScrollView), const Offset(0, -100));
    await tester.pump();

    // Search field should still be visible (now in app bar)
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Network status changes should trigger UI updates',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: locationBloc,
          child: const HomePage(),
        ),
      ),
    );

    // Simulate network disconnection
    mockNetworkChecker.setConnectionStatus(false);
    await tester.pump();

    // Verify that error message is shown
    expect(find.text('No internet connection'), findsOneWidget);

    // Simulate network reconnection
    mockNetworkChecker.setConnectionStatus(true);
    await tester.pump();

    // Verify that success message is shown
    expect(find.text('Internet connection restored'), findsOneWidget);
  });
}
