import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:weather_app_assignment/data/repositories/location_repository.dart';
import 'package:weather_app_assignment/data/service_manager.dart';
import 'package:weather_app_assignment/data/services/location_service.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';
import 'package:weather_app_assignment/data/api_client.dart';

// Simple mock classes
class MockLocationService implements LocationService {
  bool failGetAllCountries = false;
  bool failGetCountryDetails = false;

  @override
  Future<Either<DataException, List<Country>>> getAllCountries() async {
    if (failGetAllCountries) {
      return left(DataException(message: 'Failed to load countries'));
    }

    return right([
      Country(
        id: 1,
        name: 'United States',
        iso2: 'US',
        iso3: 'USA',
        capital: 'Washington',
        currency: 'USD',
        region: 'Americas',
        subregion: 'Northern America',
        emoji: '🇺🇸',
        emojiU: 'U+1F1FA U+1F1F8',
      ),
      Country(
        id: 2,
        name: 'Canada',
        iso2: 'CA',
        iso3: 'CAN',
        capital: 'Ottawa',
        currency: 'CAD',
        region: 'Americas',
        subregion: 'Northern America',
        emoji: '🇨🇦',
        emojiU: 'U+1F1E8 U+1F1E6',
      ),
    ]);
  }

  @override
  Future<Either<DataException, Country>> getCountryDetails(String iso2) async {
    if (failGetCountryDetails) {
      return left(DataException(message: 'Country not found'));
    }

    if (iso2 == 'US') {
      return right(Country(
        id: 1,
        name: 'United States',
        iso2: 'US',
        iso3: 'USA',
        capital: 'Washington',
        currency: 'USD',
        region: 'Americas',
        subregion: 'Northern America',
        emoji: '🇺🇸',
        emojiU: 'U+1F1FA U+1F1F8',
      ));
    } else {
      return left(DataException(message: 'Country not found'));
    }
  }

  @override
  ApiClient get client => throw UnimplementedError();
}

class MockServiceManager implements ServiceManager {
  final MockLocationService _locationService;

  MockServiceManager(this._locationService);

  @override
  LocationService get locationService => _locationService;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockLocationService mockLocationService;
  late MockServiceManager mockServiceManager;
  late LocationRepository locationRepository;

  setUp(() {
    mockLocationService = MockLocationService();
    mockServiceManager = MockServiceManager(mockLocationService);
    locationRepository = LocationRepository(mockServiceManager);
  });

  group('getAllCountries', () {
    test('returns countries when service call is successful', () async {
      // Act
      final result = await locationRepository.getAllCountries();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return a failure'),
        (countries) {
          expect(countries.length, equals(2));
          expect(countries[0].name, equals('United States'));
          expect(countries[1].name, equals('Canada'));
        },
      );
    });

    test('returns DataException when service call fails', () async {
      // Arrange
      mockLocationService.failGetAllCountries = true;

      // Act
      final result = await locationRepository.getAllCountries();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(exception.message, equals('Failed to load countries'));
        },
        (countries) => fail('Should not return countries'),
      );
    });
  });

  group('getCountryDetails', () {
    const testIso2 = 'US';

    test('returns country details when service call is successful', () async {
      // Act
      final result = await locationRepository.getCountryDetails(testIso2);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return a failure'),
        (country) {
          expect(country.name, equals('United States'));
          expect(country.iso2, equals('US'));
        },
      );
    });

    test('returns DataException when service call fails', () async {
      // Arrange
      mockLocationService.failGetCountryDetails = true;

      // Act
      final result = await locationRepository.getCountryDetails(testIso2);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(exception.message, equals('Country not found'));
        },
        (country) => fail('Should not return country'),
      );
    });
  });
}
