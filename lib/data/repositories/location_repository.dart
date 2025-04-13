import 'package:fpdart/fpdart.dart';
import '../service_manager.dart';
import '../models/city.dart';
import '../models/country.dart';
import '../models/state.dart';
import '../exception/DataException.dart';
import 'i_location_repository.dart';

class LocationRepository implements ILocationRepository {
  final ServiceManager _serviceManager;

  LocationRepository(ServiceManager serviceManager)
      : _serviceManager = serviceManager;

  @override
  Future<Either<DataException, List<Country>>> getAllCountries() {
    return _serviceManager.locationService.getAllCountries();
  }

  @override
  Future<Either<DataException, Country>> getCountryDetails(String iso2) {
    return _serviceManager.locationService.getCountryDetails(iso2);
  }
}
