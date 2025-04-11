import '../models/city.dart';
import '../models/country.dart';
import '../models/state.dart';

/// Custom result wrapper
class Result<T> {
  final T? data;
  final Exception? error;
  final bool isSuccess;

  Result.success(this.data)
      : error = null,
        isSuccess = true;
  Result.failure(this.error)
      : data = null,
        isSuccess = false;
}

abstract class ILocationRepository {
  /// Get a list of all countries
  Future<Result<List<Country>>> getAllCountries();

  /// Get country details from ISO2 code
  Future<Result<Country>> getCountryDetails(String iso2);

  /// Get a list of all states
  Future<Result<List<State>>> getAllStates();

  /// Get a list of states by country
  Future<Result<List<State>>> getStatesByCountry(String countryIso2);

  /// Get state details
  Future<Result<State>> getStateDetails(String countryIso2, String stateIso2);

  /// Get a list of cities by state and country
  Future<Result<List<City>>> getCitiesByStateAndCountry(
      String countryIso2, String stateIso2);

  /// Get a list of cities by country
  Future<Result<List<City>>> getCitiesByCountry(String countryIso2);
}
