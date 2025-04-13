import 'package:fpdart/fpdart.dart';
import '../models/country.dart';
import '../exception/DataException.dart';

abstract class ILocationRepository {
  /// Get a list of all countries
  Future<Either<DataException, List<Country>>> getAllCountries();

  /// Get country details from ISO2 code
  Future<Either<DataException, Country>> getCountryDetails(String iso2);
}
