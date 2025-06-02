import 'package:fpdart/fpdart.dart';
import '../../entities/country_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/i_location_repository.dart';
import '../base_usecase.dart';

class GetCountriesUseCase implements UseCaseNoParams<List<CountryEntity>> {
  final ILocationRepository repository;

  const GetCountriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CountryEntity>>> call() async {
    return await repository.getAllCountries();
  }
}
