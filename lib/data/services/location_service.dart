import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import '../api_client.dart';
import '../models/city.dart';
import '../models/country.dart';
import '../models/state.dart';
import '../exception/DataException.dart';
import '../../core/utils/network_error_handler.dart';

/// Service to handle location-related API requests
class LocationService {
  final String _baseUrl = 'https://api.countrystatecity.in/v1';
  final String _apiKey;
  final ApiClient _client;

  LocationService({required String apiKey, ApiClient? client})
      : _apiKey = apiKey,
        _client = client ?? ApiClient();

  ApiClient get client => _client;

  Map<String, String> get _headers => {
        'X-CSCAPI-KEY': _apiKey,
        'Content-Type': 'application/json',
      };

  /// Get a list of all countries
  Future<Either<DataException, List<Country>>> getAllCountries() async {
    try {
      final response = await _client.get(
        '$_baseUrl/countries',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final countries = data.map((json) => Country.fromJson(json)).toList();
        return right(countries);
      } else {
        return left(NetworkErrorHandler.createHttpException(
          response.statusCode ?? 0,
          response.data,
          customMessage: 'Failed to load countries',
        ));
      }
    } on DioException catch (e) {
      return left(NetworkErrorHandler.handleDioException(e));
    } catch (e) {
      return left(NetworkErrorHandler.createGenericException(e));
    }
  }

  /// Get country details from ISO2 code
  Future<Either<DataException, Country>> getCountryDetails(String iso2) async {
    try {
      final response = await _client.get(
        '$_baseUrl/countries/$iso2',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return right(Country.fromJson(data));
      } else {
        return left(NetworkErrorHandler.createHttpException(
          response.statusCode ?? 0,
          response.data,
          customMessage: 'Failed to load country details',
        ));
      }
    } on DioException catch (e) {
      return left(NetworkErrorHandler.handleDioException(e));
    } catch (e) {
      return left(NetworkErrorHandler.createGenericException(e));
    }
  }
}
