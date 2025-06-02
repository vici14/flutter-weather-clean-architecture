import '../../domain/entities/weather_entity.dart';
import '../models/weather_forecast.dart';

class WeatherMapper {
  static WeatherEntity toEntity(WeatherForecast model) {
    return WeatherEntity(
      lat: model.lat,
      lon: model.lon,
      timezone: model.timezone,
      timezoneOffset: model.timezoneOffset,
      current: model.current != null
          ? _currentWeatherToEntity(model.current!)
          : null,
      daily: model.daily.map(_dailyForecastToEntity).toList(),
    );
  }

  static WeatherForecast toModel(WeatherEntity entity) {
    return WeatherForecast(
      lat: entity.lat,
      lon: entity.lon,
      timezone: entity.timezone,
      timezoneOffset: entity.timezoneOffset,
      current: entity.current != null
          ? _currentWeatherToModel(entity.current!)
          : null,
      daily: entity.daily.map(_dailyForecastToModel).toList(),
    );
  }

  static CurrentWeatherEntity _currentWeatherToEntity(CurrentWeather model) {
    return CurrentWeatherEntity(
      dt: model.dt,
      sunrise: model.sunrise,
      sunset: model.sunset,
      temp: model.temp,
      feelsLike: model.feelsLike,
      humidity: model.humidity,
      weather: model.weather.map(_weatherConditionToEntity).toList(),
    );
  }

  static CurrentWeather _currentWeatherToModel(CurrentWeatherEntity entity) {
    return CurrentWeather(
      dt: entity.dt,
      sunrise: entity.sunrise,
      sunset: entity.sunset,
      temp: entity.temp,
      feelsLike: entity.feelsLike,
      humidity: entity.humidity,
      weather: entity.weather.map(_weatherConditionToModel).toList(),
    );
  }

  static DailyForecastEntity dailyForecastToEntity(DailyForecast model) {
    return DailyForecastEntity(
      dt: model.dt,
      sunrise: model.sunrise,
      sunset: model.sunset,
      moonrise: model.moonrise,
      moonset: model.moonset,
      moonPhase: model.moonPhase,
      summary: model.summary,
      temp: _tempRangeToEntity(model.temp),
      feelsLike:
          model.feelsLike != null ? _feelsLikeToEntity(model.feelsLike!) : null,
      pressure: model.pressure,
      humidity: model.humidity,
      dewPoint: model.dewPoint,
      windSpeed: model.windSpeed,
      windDeg: model.windDeg,
      windGust: model.windGust,
      weather: model.weather.map(_weatherConditionToEntity).toList(),
      clouds: model.clouds,
      pop: model.pop,
      rain: model.rain,
      uvi: model.uvi,
    );
  }

  static DailyForecastEntity _dailyForecastToEntity(DailyForecast model) {
    return dailyForecastToEntity(model);
  }

  static DailyForecast dailyForecastToModel(DailyForecastEntity entity) {
    return DailyForecast(
      dt: entity.dt,
      sunrise: entity.sunrise,
      sunset: entity.sunset,
      moonrise: entity.moonrise,
      moonset: entity.moonset,
      moonPhase: entity.moonPhase,
      summary: entity.summary,
      temp: _tempRangeToModel(entity.temp),
      feelsLike: entity.feelsLike != null
          ? _feelsLikeToModel(entity.feelsLike!)
          : null,
      pressure: entity.pressure,
      humidity: entity.humidity,
      dewPoint: entity.dewPoint,
      windSpeed: entity.windSpeed,
      windDeg: entity.windDeg,
      windGust: entity.windGust,
      weather: entity.weather.map(_weatherConditionToModel).toList(),
      clouds: entity.clouds,
      pop: entity.pop,
      rain: entity.rain,
      uvi: entity.uvi,
    );
  }

  static DailyForecast _dailyForecastToModel(DailyForecastEntity entity) {
    return dailyForecastToModel(entity);
  }

  static TempRangeEntity _tempRangeToEntity(TempRange model) {
    return TempRangeEntity(
      day: model.day,
      min: model.min,
      max: model.max,
      night: model.night,
      eve: model.eve,
      morn: model.morn,
    );
  }

  static TempRange _tempRangeToModel(TempRangeEntity entity) {
    return TempRange(
      day: entity.day,
      min: entity.min,
      max: entity.max,
      night: entity.night,
      eve: entity.eve,
      morn: entity.morn,
    );
  }

  static FeelsLikeEntity _feelsLikeToEntity(FeelsLike model) {
    return FeelsLikeEntity(
      day: model.day,
      night: model.night,
      eve: model.eve,
      morn: model.morn,
    );
  }

  static FeelsLike _feelsLikeToModel(FeelsLikeEntity entity) {
    return FeelsLike(
      day: entity.day,
      night: entity.night,
      eve: entity.eve,
      morn: entity.morn,
    );
  }

  static WeatherConditionEntity _weatherConditionToEntity(
      WeatherCondition model) {
    return WeatherConditionEntity(
      id: model.id,
      main: model.main,
      description: model.description,
      icon: model.icon,
    );
  }

  static WeatherCondition _weatherConditionToModel(
      WeatherConditionEntity entity) {
    return WeatherCondition(
      id: entity.id,
      main: entity.main,
      description: entity.description,
      icon: entity.icon,
    );
  }
}
