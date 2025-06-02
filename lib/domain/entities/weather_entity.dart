import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final double lat;
  final double lon;
  final String timezone;
  final int timezoneOffset;
  final CurrentWeatherEntity? current;
  final List<DailyForecastEntity> daily;

  const WeatherEntity({
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.timezoneOffset,
    this.current,
    required this.daily,
  });

  @override
  List<Object?> get props =>
      [lat, lon, timezone, timezoneOffset, current, daily];
}

class CurrentWeatherEntity extends Equatable {
  final int dt;
  final int sunrise;
  final int sunset;
  final double temp;
  final double feelsLike;
  final int humidity;
  final List<WeatherConditionEntity> weather;

  const CurrentWeatherEntity({
    required this.dt,
    required this.sunrise,
    required this.sunset,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.weather,
  });

  @override
  List<Object> get props =>
      [dt, sunrise, sunset, temp, feelsLike, humidity, weather];
}

class DailyForecastEntity extends Equatable {
  final int dt;
  final int sunrise;
  final int sunset;
  final int? moonrise;
  final int? moonset;
  final double? moonPhase;
  final String? summary;
  final TempRangeEntity temp;
  final FeelsLikeEntity? feelsLike;
  final int? pressure;
  final int? humidity;
  final double? dewPoint;
  final double? windSpeed;
  final int? windDeg;
  final double? windGust;
  final List<WeatherConditionEntity> weather;
  final int? clouds;
  final double? pop;
  final double? rain;
  final double? uvi;

  const DailyForecastEntity({
    required this.dt,
    required this.sunrise,
    required this.sunset,
    this.moonrise,
    this.moonset,
    this.moonPhase,
    this.summary,
    required this.temp,
    this.feelsLike,
    this.pressure,
    this.humidity,
    this.dewPoint,
    this.windSpeed,
    this.windDeg,
    this.windGust,
    required this.weather,
    this.clouds,
    this.pop,
    this.rain,
    this.uvi,
  });

  @override
  List<Object?> get props => [
        dt,
        sunrise,
        sunset,
        moonrise,
        moonset,
        moonPhase,
        summary,
        temp,
        feelsLike,
        pressure,
        humidity,
        dewPoint,
        windSpeed,
        windDeg,
        windGust,
        weather,
        clouds,
        pop,
        rain,
        uvi
      ];
}

class TempRangeEntity extends Equatable {
  final double day;
  final double min;
  final double max;
  final double night;
  final double eve;
  final double morn;

  const TempRangeEntity({
    required this.day,
    required this.min,
    required this.max,
    required this.night,
    required this.eve,
    required this.morn,
  });

  int get avgTemp => ((min + max) / 2).round();

  @override
  List<Object> get props => [day, min, max, night, eve, morn];
}

class FeelsLikeEntity extends Equatable {
  final double day;
  final double night;
  final double eve;
  final double morn;

  const FeelsLikeEntity({
    required this.day,
    required this.night,
    required this.eve,
    required this.morn,
  });

  @override
  List<Object> get props => [day, night, eve, morn];
}

class WeatherConditionEntity extends Equatable {
  final int id;
  final String main;
  final String description;
  final String icon;

  const WeatherConditionEntity({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  @override
  List<Object> get props => [id, main, description, icon];
}
