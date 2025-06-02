import 'package:fpdart/fpdart.dart';
import '../../entities/country_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/i_location_repository.dart';
import '../base_usecase.dart';

class GetCountryDetailsParams {
  final String iso2;

  const GetCountryDetailsParams({required this.iso2});
}

class GetCountryDetailsUseCase
    implements UseCase<CountryEntity, GetCountryDetailsParams> {
  final ILocationRepository repository;

  const GetCountryDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, CountryEntity>> call(
      GetCountryDetailsParams params) async {
    return await repository.getCountryDetails(params.iso2);
  }
}
