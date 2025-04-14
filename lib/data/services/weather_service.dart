import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import '../api_client.dart';
import '../models/weather_forecast.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import '../../core/utils/network_error_handler.dart';

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
  Future<Either<DataException, WeatherForecast>> getWeatherForecast({
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
        return right(WeatherForecast.fromJson(data));
      } else {
        return left(NetworkErrorHandler.createHttpException(
          response.statusCode ?? 0,
          response.data,
          customMessage: 'Failed to load weather forecast',
        ));
      }
    } on DioException catch (e) {
      return left(NetworkErrorHandler.handleDioException(e));
    } catch (e) {
      return left(NetworkErrorHandler.createGenericException(e));
    }
  }

  /// Get 4 days ahead forecast for a location
  Future<Either<DataException, List<DailyForecast>>> getFourDaysForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  }) async {
    final forecastResult = await getWeatherForecast(
      lat: lat,
      lon: lon,
      units: units,
    );

    return forecastResult.fold(
      (error) => left(error),
      (forecast) => right(forecast.daily.toList()),
    );
  }
}
