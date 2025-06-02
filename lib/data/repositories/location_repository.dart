import 'package:fpdart/fpdart.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/failures/failure.dart';
import '../../domain/failures/api_failure.dart';
import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/i_location_repository.dart';
import '../mappers/country_mapper.dart';
import '../service_manager.dart';
import '../exception/DataException.dart';

class LocationRepository implements ILocationRepository {
  final ServiceManager _serviceManager;

  LocationRepository(ServiceManager serviceManager)
      : _serviceManager = serviceManager;

  @override
  Future<Either<Failure, List<CountryEntity>>> getAllCountries() async {
    final result = await _serviceManager.locationService.getAllCountries();

    return result.fold(
      (dataException) => Left(_mapDataExceptionToFailure(dataException)),
      (countries) => Right(CountryMapper.toEntityList(countries)),
    );
  }

  @override
  Future<Either<Failure, CountryEntity>> getCountryDetails(String iso2) async {
    final result =
        await _serviceManager.locationService.getCountryDetails(iso2);

    return result.fold(
      (dataException) => Left(_mapDataExceptionToFailure(dataException)),
      (country) => Right(CountryMapper.toEntity(country)),
    );
  }

  Failure _mapDataExceptionToFailure(DataException dataException) {
    final message = dataException.message ?? 'Unknown error occurred';

    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection') ||
        message.toLowerCase().contains('timeout')) {
      return NetworkFailure(message: message);
    }

    if (message.toLowerCase().contains('api key') ||
        message.toLowerCase().contains('unauthorized')) {
      return ApiFailure.invalidApiKey();
    }

    if (message.toLowerCase().contains('not found')) {
      return ApiFailure.notFound();
    }

    if (message.toLowerCase().contains('rate limit') ||
        message.toLowerCase().contains('too many requests')) {
      return ApiFailure.rateLimitExceeded();
    }

    return ApiFailure(message: message);
  }
}
