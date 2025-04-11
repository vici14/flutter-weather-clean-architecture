import 'dart:convert';
import '../api_client.dart';

/// Result class for weather service responses
class WeatherResult<T> {
  final T? data;
  final Exception? error;
  final bool isSuccess;

  WeatherResult.success(this.data)
      : error = null,
        isSuccess = true;
  WeatherResult.failure(this.error)
      : data = null,
        isSuccess = false;
}

/// Weather forecast data model
class WeatherForecast {
  final double lat;
  final double lon;
  final String timezone;
  final int timezoneOffset;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  WeatherForecast({
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.timezoneOffset,
    required this.current,
    required this.daily,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      lat: json['lat'].toDouble(),
      lon: json['lon'].toDouble(),
      timezone: json['timezone'],
      timezoneOffset: json['timezone_offset'],
      current: CurrentWeather.fromJson(json['current']),
      daily: (json['daily'] as List)
          .map((day) => DailyForecast.fromJson(day))
          .toList(),
    );
  }
}

/// Current weather data model
class CurrentWeather {
  final int dt;
  final int sunrise;
  final int sunset;
  final double temp;
  final double feelsLike;
  final int humidity;
  final List<WeatherCondition> weather;

  CurrentWeather({
    required this.dt,
    required this.sunrise,
    required this.sunset,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.weather,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      dt: json['dt'],
      sunrise: json['sunrise'],
      sunset: json['sunset'],
      temp: json['temp'].toDouble(),
      feelsLike: json['feels_like'].toDouble(),
      humidity: json['humidity'],
      weather: (json['weather'] as List)
          .map((w) => WeatherCondition.fromJson(w))
          .toList(),
    );
  }
}

/// Daily forecast data model
class DailyForecast {
  final int dt;
  final int sunrise;
  final int sunset;
  final TempRange temp;
  final List<WeatherCondition> weather;

  DailyForecast({
    required this.dt,
    required this.sunrise,
    required this.sunset,
    required this.temp,
    required this.weather,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      dt: json['dt'],
      sunrise: json['sunrise'],
      sunset: json['sunset'],
      temp: TempRange.fromJson(json['temp']),
      weather: (json['weather'] as List)
          .map((w) => WeatherCondition.fromJson(w))
          .toList(),
    );
  }
}

/// Temperature range data model
class TempRange {
  final double day;
  final double min;
  final double max;
  final double night;
  final double eve;
  final double morn;

  TempRange({
    required this.day,
    required this.min,
    required this.max,
    required this.night,
    required this.eve,
    required this.morn,
  });

  factory TempRange.fromJson(Map<String, dynamic> json) {
    return TempRange(
      day: json['day'].toDouble(),
      min: json['min'].toDouble(),
      max: json['max'].toDouble(),
      night: json['night'].toDouble(),
      eve: json['eve'].toDouble(),
      morn: json['morn'].toDouble(),
    );
  }
}

/// Weather condition data model
class WeatherCondition {
  final int id;
  final String main;
  final String description;
  final String icon;

  WeatherCondition({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      id: json['id'],
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}

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
      final fourDaysForecast =
          forecastResult.data!.daily.take(5).skip(1).toList();
      return WeatherResult.success(fourDaysForecast);
    } else {
      return WeatherResult.failure(
          forecastResult.error ?? Exception('Unknown error'));
    }
  }
}
