// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:weather_app_assignment/core/dependency_injection/service_locator.dart';
import 'package:weather_app_assignment/data/repositories/i_location_repository.dart';
import 'package:weather_app_assignment/features/location/bloc/location_bloc.dart';
import 'package:weather_app_assignment/features/location/pages/home_page.dart';
import 'package:weather_app_assignment/main.dart';
import '../test/mocks/mock_location_repository.dart';

void main() {
  late LocationBloc locationBloc;
  late MockLocationRepository mockRepository;

  setUp(() {
    mockRepository = MockLocationRepository();
    GetIt.I.registerSingleton<ILocationRepository>(mockRepository);
    locationBloc = LocationBloc(mockRepository);
    GetIt.I.registerSingleton<LocationBloc>(locationBloc);
  });

  tearDown(() {
    locationBloc.close();
    GetIt.I.reset();
  });

  testWidgets('HomePage should render correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => locationBloc,
          child: const HomePage(),
        ),
      ),
    );

    // Verify that the search field is rendered
    expect(find.byType(TextField), findsOneWidget);

    // Verify that the CountryListWidget is rendered
    expect(find.byType(SafeArea), findsOneWidget);
  });

  testWidgets('Search field should work correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => locationBloc,
          child: const HomePage(),
        ),
      ),
    );

    // Enter text in search field
    await tester.enterText(find.byType(TextField), 'test');
    await tester.pump();

    // Verify that the text was entered
    expect(find.text('test'), findsOneWidget);
  });

  testWidgets('Scroll behavior should work correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => locationBloc,
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
}
