import 'package:fpdart/fpdart.dart';
import '../entities/country_entity.dart';
import '../failures/failure.dart';

abstract class ILocationRepository {
  Future<Either<Failure, List<CountryEntity>>> getAllCountries();

  Future<Either<Failure, CountryEntity>> getCountryDetails(String iso2);
}
