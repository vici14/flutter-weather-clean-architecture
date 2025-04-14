import 'package:fpdart/fpdart.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/data/repositories/i_location_repository.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';

class MockLocationRepository implements ILocationRepository {
  bool _shouldFail = false;

  MockLocationRepository({bool shouldFail = false}) {
    _shouldFail = shouldFail;
  }

  @override
  Future<Either<DataException, List<Country>>> getAllCountries() async {
    if (_shouldFail) {
      return left(DataException(message: 'Failed to load countries'));
    }

    return right([
      const Country(
        id: 1,
        name: 'United States',
        iso2: 'US',
        iso3: 'USA',
        phonecode: '1',
        capital: 'Washington, D.C.',
        currency: 'USD',
        native: 'United States',
        emoji: '🇺🇸',
      ),
      const Country(
        id: 2,
        name: 'United Kingdom',
        iso2: 'GB',
        iso3: 'GBR',
        phonecode: '44',
        capital: 'London',
        currency: 'GBP',
        native: 'United Kingdom',
        emoji: '🇬🇧',
      ),
    ]);
  }

  @override
  Future<Either<DataException, Country>> getCountryDetails(String iso2) async {
    if (_shouldFail) {
      return left(DataException(message: 'Failed to load country details'));
    }

    return right(
      const Country(
        id: 1,
        name: 'United States',
        iso2: 'US',
        iso3: 'USA',
        phonecode: '1',
        capital: 'Washington, D.C.',
        currency: 'USD',
        native: 'United States',
        emoji: '🇺🇸',
      ),
    );
  }

  void setShouldFail(bool shouldFail) {
    _shouldFail = shouldFail;
  }
}
