import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/data/models/weather_forecast.dart';

/// Register all required dummy values for Either types used in tests
void registerDummyValues() {
  // Country-related dummy values
  provideDummy<Either<DataException, List<Country>>>(
    Right<DataException, List<Country>>([]),
  );

  provideDummy<Either<DataException, Country>>(
    Right<DataException, Country>(const Country(
      id: 1,
      name: 'Test Country',
      iso2: 'TC',
      capital: 'Test Capital',
      region: 'Test Region',
    )),
  );

  // Weather-related dummy values
  provideDummy<Either<DataException, WeatherForecast>>(
    Right<DataException, WeatherForecast>(WeatherForecast(
      lat: 0,
      lon: 0,
      timezone: 'UTC',
      timezoneOffset: 0,
      current: CurrentWeather(
        dt: 1627246800,
        sunrise: 1627207155,
        sunset: 1627260014,
        temp: 28.5,
        feelsLike: 30.2,
        humidity: 65,
        weather: [
          WeatherCondition(
            id: 800,
            main: 'Clear',
            description: 'clear sky',
            icon: '01d',
          ),
        ],
      ),
      daily: [],
    )),
  );

  provideDummy<Either<DataException, List<DailyForecast>>>(
    Right<DataException, List<DailyForecast>>([]),
  );
}
