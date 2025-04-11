import 'package:flutter/material.dart';
import '../screens/weather_screen.dart';
import '../screens/home_screen.dart';
import '../models/location_model.dart';

class AppRoutes {
  static const String home = '/';
  static const String weatherDetails = '/weather-details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case weatherDetails:
        final Location? location = settings.arguments as Location?;
        return MaterialPageRoute(
          builder: (_) => WeatherScreen(location: location),
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
