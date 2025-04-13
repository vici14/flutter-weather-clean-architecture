import '../models/country.dart';
import '../models/result.dart';

abstract class ILocationRepository {
  /// Get a list of all countries
  Future<Result<List<Country>>> getAllCountries();

  /// Get country details from ISO2 code
  Future<Result<Country>> getCountryDetails(String iso2);

}
