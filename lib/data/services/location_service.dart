import 'dart:convert';
import '../api_client.dart';
import '../models/city.dart';
import '../models/country.dart';
import '../models/state.dart';
import '../repositories/i_location_repository.dart';

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
  Future<Result<List<Country>>> getAllCountries() async {
    try {
      final response = await _client.get(
        '$_baseUrl/countries',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final countries = data.map((json) => Country.fromJson(json)).toList();
        return Result.success(countries);
      } else {
        return Result.failure(
            Exception('Failed to load countries: ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(Exception('Network error: $e'));
    }
  }

  /// Get country details from ISO2 code
  Future<Result<Country>> getCountryDetails(String iso2) async {
    try {
      final response = await _client.get(
        '$_baseUrl/countries/$iso2',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return Result.success(Country.fromJson(data));
      } else {
        return Result.failure(Exception(
            'Failed to load country details: ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(Exception('Network error: $e'));
    }
  }

  /// Get a list of all states
  Future<Result<List<State>>> getAllStates() async {
    try {
      final response = await _client.get(
        '$_baseUrl/states',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final states = data.map((json) => State.fromJson(json)).toList();
        return Result.success(states);
      } else {
        return Result.failure(
            Exception('Failed to load states: ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(Exception('Network error: $e'));
    }
  }

  /// Get a list of states by country
  Future<Result<List<State>>> getStatesByCountry(String countryIso2) async {
    try {
      final response = await _client.get(
        '$_baseUrl/countries/$countryIso2/states',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final states = data.map((json) => State.fromJson(json)).toList();
        return Result.success(states);
      } else {
        return Result.failure(
            Exception('Failed to load states: ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(Exception('Network error: $e'));
    }
  }

  /// Get state details
  Future<Result<State>> getStateDetails(
      String countryIso2, String stateIso2) async {
    try {
      final response = await _client.get(
        '$_baseUrl/countries/$countryIso2/states/$stateIso2',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return Result.success(State.fromJson(data));
      } else {
        return Result.failure(
            Exception('Failed to load state details: ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(Exception('Network error: $e'));
    }
  }

  /// Get a list of cities by state and country
  Future<Result<List<City>>> getCitiesByStateAndCountry(
      String countryIso2, String stateIso2) async {
    try {
      final response = await _client.get(
        '$_baseUrl/countries/$countryIso2/states/$stateIso2/cities',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final cities = data.map((json) => City.fromJson(json)).toList();
        return Result.success(cities);
      } else {
        return Result.failure(
            Exception('Failed to load cities: ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(Exception('Network error: $e'));
    }
  }

  /// Get a list of cities by country
  Future<Result<List<City>>> getCitiesByCountry(String countryIso2) async {
    try {
      final response = await _client.get(
        '$_baseUrl/countries/$countryIso2/cities',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final cities = data.map((json) => City.fromJson(json)).toList();
        return Result.success(cities);
      } else {
        return Result.failure(
            Exception('Failed to load cities: ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(Exception('Network error: $e'));
    }
  }
}
