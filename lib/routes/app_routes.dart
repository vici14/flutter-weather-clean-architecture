import 'package:flutter/material.dart';
import '../screens/weather_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String weatherDetails = '/weather-details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const WeatherScreen());
      default:
        return MaterialPageRoute(builder: (_) => const WeatherScreen());
    }
  }
}
