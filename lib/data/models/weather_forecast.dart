import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_forecast.freezed.dart';
part 'weather_forecast.g.dart';

@freezed
class WeatherForecast with _$WeatherForecast {
  const factory WeatherForecast({
    required double lat,
    required double lon,
    required String timezone,
    @JsonKey(name: 'timezone_offset') required int timezoneOffset,
    CurrentWeather? current,
    required List<DailyForecast> daily,
  }) = _WeatherForecast;

  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastFromJson(json);
}

@freezed
class CurrentWeather with _$CurrentWeather {
  const factory CurrentWeather({
    required int dt,
    required int sunrise,
    required int sunset,
    required double temp,
    @JsonKey(name: 'feels_like') required double feelsLike,
    required int humidity,
    required List<WeatherCondition> weather,
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherFromJson(json);
}

@freezed
class DailyForecast with _$DailyForecast {
  const factory DailyForecast({
    required int dt,
    required int sunrise,
    required int sunset,
    int? moonrise,
    int? moonset,
    @JsonKey(name: 'moon_phase') double? moonPhase,
    String? summary,
    required TempRange temp,
    @JsonKey(name: 'feels_like') FeelsLike? feelsLike,
    int? pressure,
    int? humidity,
    @JsonKey(name: 'dew_point') double? dewPoint,
    @JsonKey(name: 'wind_speed') double? windSpeed,
    @JsonKey(name: 'wind_deg') int? windDeg,
    @JsonKey(name: 'wind_gust') double? windGust,
    required List<WeatherCondition> weather,
    int? clouds,
    double? pop,
    double? rain,
    double? uvi,
  }) = _DailyForecast;

  factory DailyForecast.fromJson(Map<String, dynamic> json) =>
      _$DailyForecastFromJson(json);
}

@freezed
class TempRange with _$TempRange {
  const factory TempRange({
    required double day,
    required double min,
    required double max,
    required double night,
    required double eve,
    required double morn,
  }) = _TempRange;

  const TempRange._();

  int get avgTemp => ((min + max) / 2).round();

  factory TempRange.fromJson(Map<String, dynamic> json) =>
      _$TempRangeFromJson(json);
}

@freezed
class FeelsLike with _$FeelsLike {
  const factory FeelsLike({
    required double day,
    required double night,
    required double eve,
    required double morn,
  }) = _FeelsLike;

  factory FeelsLike.fromJson(Map<String, dynamic> json) =>
      _$FeelsLikeFromJson(json);
}

@freezed
class WeatherCondition with _$WeatherCondition {
  const factory WeatherCondition({
    required int id,
    required String main,
    required String description,
    required String icon,
  }) = _WeatherCondition;

  factory WeatherCondition.fromJson(Map<String, dynamic> json) =>
      _$WeatherConditionFromJson(json);
}
