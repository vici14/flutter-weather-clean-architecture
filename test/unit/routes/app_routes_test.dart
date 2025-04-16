import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/routes/app_routes.dart';
import 'package:weather_app_assignment/features/location/pages/home_page.dart';
import 'package:weather_app_assignment/features/weather/pages/weather_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppRoutes', () {
    test('route constants should be defined correctly', () {
      expect(AppRoutes.home, '/');
      expect(AppRoutes.weatherDetails, '/weather-details');
    });

    test('onGenerateRoute should return HomePage for home route', () {
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(name: AppRoutes.home),
      ) as MaterialPageRoute;

      // Verify correct route was created
      expect(route, isA<MaterialPageRoute>());
      expect(route.settings.name, AppRoutes.home);

      // Build the widget to verify correct widget is returned
      final widget = route.builder(MockBuildContext());
      expect(widget, isA<HomePage>());
    });

    test('onGenerateRoute should return WeatherPage for weather details route',
        () {
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(name: AppRoutes.weatherDetails),
      ) as MaterialPageRoute;

      // Verify correct route was created
      expect(route, isA<MaterialPageRoute>());
      expect(route.settings.name, AppRoutes.weatherDetails);

      // Build the widget to verify correct widget is returned
      final widget = route.builder(MockBuildContext());
      expect(widget, isA<WeatherPage>());
    });

    test('onGenerateRoute should return error page for unknown routes', () {
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(name: '/unknown-route'),
      ) as MaterialPageRoute;

      // Verify correct route was created
      expect(route, isA<MaterialPageRoute>());
      expect(route.settings.name, '/unknown-route');

      // Build the widget to verify error scaffold is returned
      final widget = route.builder(MockBuildContext());
      expect(widget, isA<Scaffold>());

      // Verify error page has expected elements
      final scaffold = widget as Scaffold;
      expect(scaffold.appBar, isA<AppBar>());

      // Check for error message in the body
      final center = scaffold.body as Center;
      final text = center.child as Text;
      expect(text.data, 'Route not found');
    });
  });
}

// Mock BuildContext for testing
class MockBuildContext extends Fake implements BuildContext {}
