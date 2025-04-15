import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:weather_app_assignment/data/services/location_service.dart';
import 'package:weather_app_assignment/data/api_client.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';

// Generate mocks for the ApiClient
@GenerateMocks([ApiClient])
import 'location_service_test.mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late LocationService locationService;
  const String testApiKey = 'test_api_key';
  final Map<String, String> expectedHeaders = {
    'X-CSCAPI-KEY': testApiKey,
    'Content-Type': 'application/json',
  };

  setUp(() {
    mockApiClient = MockApiClient();
    locationService = LocationService(
      apiKey: testApiKey,
      client: mockApiClient,
    );
  });

  group('getAllCountries', () {
    final mockCountriesJson = [
      {
        'id': 1,
        'name': 'United States',
        'iso2': 'US',
        'iso3': 'USA',
        'capital': 'Washington',
        'currency': 'USD',
        'region': 'Americas',
        'subregion': 'Northern America',
        'emoji': '🇺🇸',
        'emojiU': 'U+1F1FA U+1F1F8',
      },
      {
        'id': 2,
        'name': 'Canada',
        'iso2': 'CA',
        'iso3': 'CAN',
        'capital': 'Ottawa',
        'currency': 'CAD',
        'region': 'Americas',
        'subregion': 'Northern America',
        'emoji': '🇨🇦',
        'emojiU': 'U+1F1E8 U+1F1E6',
      },
    ];

    test('returns list of countries when API call is successful', () async {
      // Arrange
      final response = Response(
        data: mockCountriesJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockApiClient.get<List<dynamic>>(
        'https://api.countrystatecity.in/v1/countries',
        headers: expectedHeaders,
      )).thenAnswer((_) async => response);

      // Act
      final result = await locationService.getAllCountries();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return a failure'),
        (countries) {
          expect(countries.length, equals(2));
          expect(countries[0].name, equals('United States'));
          expect(countries[0].iso2, equals('US'));
          expect(countries[1].name, equals('Canada'));
          expect(countries[1].iso2, equals('CA'));
        },
      );
    });

    test('returns DataException when API returns error code', () async {
      // Arrange
      final response = Response(
        data: {'message': 'Invalid API key'},
        statusCode: 401,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockApiClient.get<Map<String, dynamic>>(
        'https://api.countrystatecity.in/v1/countries',
        headers: expectedHeaders,
      )).thenAnswer((_) async => response);

      // Act
      final result = await locationService.getAllCountries();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(exception.message, contains('Failed to load countries'));
        },
        (countries) => fail('Should not return countries'),
      );
    });

    test('returns DataException when API call throws DioException', () async {
      // Arrange
      when(mockApiClient.get<List<dynamic>>(
        'https://api.countrystatecity.in/v1/countries',
        headers: expectedHeaders,
      )).thenThrow(DioException(
        type: DioExceptionType.connectionTimeout,
        error: 'Connection timeout',
        requestOptions: RequestOptions(path: ''),
      ));

      // Act
      final result = await locationService.getAllCountries();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(exception.message, contains('Connection timeout'));
        },
        (countries) => fail('Should not return countries'),
      );
    });

    test('returns DataException when API call throws unexpected error',
        () async {
      // Arrange
      when(mockApiClient.get<List<dynamic>>(
        'https://api.countrystatecity.in/v1/countries',
        headers: expectedHeaders,
      )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await locationService.getAllCountries();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(exception.message, equals('Unexpected error occurred'));
        },
        (countries) => fail('Should not return countries'),
      );
    });
  });

  group('getCountryDetails', () {
    const testIso2 = 'US';
    final mockCountryJson = {
      'id': 1,
      'name': 'United States',
      'iso2': 'US',
      'iso3': 'USA',
      'capital': 'Washington',
      'currency': 'USD',
      'region': 'Americas',
      'subregion': 'Northern America',
      'emoji': '🇺🇸',
      'emojiU': 'U+1F1FA U+1F1F8',
    };

    test('returns country details when API call is successful', () async {
      // Arrange
      final response = Response(
        data: mockCountryJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockApiClient.get<Map<String, dynamic>>(
        'https://api.countrystatecity.in/v1/countries/$testIso2',
        headers: expectedHeaders,
      )).thenAnswer((_) async => response);

      // Act
      final result = await locationService.getCountryDetails(testIso2);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return a failure'),
        (country) {
          expect(country.name, equals('United States'));
          expect(country.iso2, equals('US'));
          expect(country.iso3, equals('USA'));
          expect(country.capital, equals('Washington'));
        },
      );
    });

    test('returns DataException when API returns error code (404)', () async {
      // Arrange
      final response = Response(
        data: {'message': 'Country not found'},
        statusCode: 404,
        requestOptions: RequestOptions(path: ''),
      );

      when(mockApiClient.get<Map<String, dynamic>>(
        'https://api.countrystatecity.in/v1/countries/$testIso2',
        headers: expectedHeaders,
      )).thenAnswer((_) async => response);

      // Act
      final result = await locationService.getCountryDetails(testIso2);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(exception.message, contains('Failed to load country details'));
        },
        (country) => fail('Should not return country'),
      );
    });

    test('returns DataException when API call throws DioException', () async {
      // Arrange
      when(mockApiClient.get<Map<String, dynamic>>(
        'https://api.countrystatecity.in/v1/countries/$testIso2',
        headers: expectedHeaders,
      )).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        error: 'Bad response',
        requestOptions: RequestOptions(path: ''),
      ));

      // Act
      final result = await locationService.getCountryDetails(testIso2);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(exception.message, equals('Service error'));
        },
        (country) => fail('Should not return country'),
      );
    });

    test('returns DataException when API call throws unexpected error',
        () async {
      // Arrange
      when(mockApiClient.get<Map<String, dynamic>>(
        'https://api.countrystatecity.in/v1/countries/$testIso2',
        headers: expectedHeaders,
      )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await locationService.getCountryDetails(testIso2);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (exception) {
          expect(exception.message, equals('Unexpected error occurred'));
        },
        (country) => fail('Should not return country'),
      );
    });
  });
}
