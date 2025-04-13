import 'dart:convert';
import '../api_client.dart';
import '../models/weather_forecast.dart';
import '../models/weather_result.dart';

/// Service to handle weather-related API requests
class WeatherService {
  final String _baseUrl = 'https://api.openweathermap.org/data/3.0';
  final String _apiKey;
  final ApiClient _client;

  WeatherService({required String apiKey, ApiClient? client})
      : _apiKey = apiKey,
        _client = client ?? ApiClient();

  ApiClient get client => _client;

  /// Get weather forecast for a location
  Future<WeatherResult<WeatherForecast>> getWeatherForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  }) async {
    try {
      final response = await _client.get(
        '$_baseUrl/onecall',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'units': units,
          'exclude': 'current,minutely,hourly,alerts',
          'appid': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return WeatherResult.success(WeatherForecast.fromJson(data));
      } else {
        return WeatherResult.failure(Exception(
            'Failed to load weather forecast: ${response.statusCode}'));
      }
    } catch (e) {
      return WeatherResult.failure(Exception('Network error: $e'));
    }
  }

  /// Get 4 days ahead forecast for a location
  Future<WeatherResult<List<DailyForecast>>> getFourDaysForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  }) async {
    final forecastResult = await getWeatherForecast(
      lat: lat,
      lon: lon,
      units: units,
    );

    if (forecastResult.isSuccess && forecastResult.data != null) {
      // Filter to get only the next 4 days (excluding today)
      final fourDaysForecast = forecastResult.data!.daily.toList();
      return WeatherResult.success(fourDaysForecast);
    } else {
      return WeatherResult.failure(
          forecastResult.error ?? Exception('Unknown error'));
    }
  }
}
