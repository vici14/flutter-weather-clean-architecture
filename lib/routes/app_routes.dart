import 'package:flutter/material.dart';
import '../features/location/pages/home_page.dart';
import '../features/weather/pages/weather_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String weatherDetails = '/weather-details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // This is where you can add middleware logic
    // For example: authentication checks, logging, analytics, etc.

    // Extract route arguments if needed
    final args = settings.arguments;

    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomePage(),
        );

      case weatherDetails:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => WeatherPage(),
        );

      default:
        // Handle unknown routes
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
