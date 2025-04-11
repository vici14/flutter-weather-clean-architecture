import '../../core/service_manager.dart';
import '../models/city.dart';
import '../models/country.dart';
import '../models/state.dart';
import 'i_location_repository.dart';

class LocationRepository implements ILocationRepository {
  final ServiceManager _serviceManager;

  LocationRepository({ServiceManager? serviceManager})
      : _serviceManager = serviceManager ?? ServiceManager();

  @override
  Future<Result<List<Country>>> getAllCountries() {
    return _serviceManager.locationService.getAllCountries();
  }

  @override
  Future<Result<Country>> getCountryDetails(String iso2) {
    return _serviceManager.locationService.getCountryDetails(iso2);
  }

  @override
  Future<Result<List<State>>> getAllStates() {
    return _serviceManager.locationService.getAllStates();
  }

  @override
  Future<Result<List<State>>> getStatesByCountry(String countryIso2) {
    return _serviceManager.locationService.getStatesByCountry(countryIso2);
  }

  @override
  Future<Result<State>> getStateDetails(String countryIso2, String stateIso2) {
    return _serviceManager.locationService
        .getStateDetails(countryIso2, stateIso2);
  }

  @override
  Future<Result<List<City>>> getCitiesByStateAndCountry(
      String countryIso2, String stateIso2) {
    return _serviceManager.locationService
        .getCitiesByStateAndCountry(countryIso2, stateIso2);
  }

  @override
  Future<Result<List<City>>> getCitiesByCountry(String countryIso2) {
    return _serviceManager.locationService.getCitiesByCountry(countryIso2);
  }
}
