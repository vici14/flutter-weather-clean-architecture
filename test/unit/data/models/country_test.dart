import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/data/models/country.dart';

void main() {
  group('Country Model Tests', () {
    test('should properly parse from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 101,
        'name': 'United States',
        'iso2': 'US',
        'iso3': 'USA',
        'phonecode': '1',
        'capital': 'Washington D.C.',
        'currency': 'USD',
        'native': 'United States',
        'emoji': '🇺🇸',
        'numeric_code': '840',
        'currency_name': 'United States dollar',
        'currency_symbol': '\$',
        'tld': '.us',
        'region': 'Americas',
        'region_id': 2,
        'subregion': 'Northern America',
        'subregion_id': 3,
        'nationality': 'American',
        'timezones':
            'UTC-10:00,UTC-09:00,UTC-08:00,UTC-07:00,UTC-06:00,UTC-05:00,UTC-04:00',
        'translations': 'json_data',
        'latitude': '38.00000000',
        'longitude': '-97.00000000',
        'emojiU': 'U+1F1FA U+1F1F8'
      };

      // Act
      final result = Country.fromJson(jsonMap);

      // Assert
      expect(result.id, 101);
      expect(result.name, 'United States');
      expect(result.iso2, 'US');
      expect(result.iso3, 'USA');
      expect(result.phonecode, '1');
      expect(result.capital, 'Washington D.C.');
      expect(result.currency, 'USD');
      expect(result.native, 'United States');
      expect(result.emoji, '🇺🇸');
      expect(result.numeric_code, '840');
      expect(result.currency_name, 'United States dollar');
      expect(result.currency_symbol, '\$');
      expect(result.tld, '.us');
      expect(result.region, 'Americas');
      expect(result.region_id, 2);
      expect(result.subregion, 'Northern America');
      expect(result.subregion_id, 3);
      expect(result.nationality, 'American');
      expect(result.timezones,
          'UTC-10:00,UTC-09:00,UTC-08:00,UTC-07:00,UTC-06:00,UTC-05:00,UTC-04:00');
      expect(result.translations, 'json_data');
      expect(result.latitude, '38.00000000');
      expect(result.longitude, '-97.00000000');
      expect(result.emojiU, 'U+1F1FA U+1F1F8');
    });

    test('should serialize to JSON properly', () {
      // Arrange
      final country = Country(
          id: 101,
          name: 'United States',
          iso2: 'US',
          iso3: 'USA',
          phonecode: '1',
          capital: 'Washington D.C.',
          currency: 'USD',
          native: 'United States',
          emoji: '🇺🇸',
          numeric_code: '840',
          currency_name: 'United States dollar',
          currency_symbol: '\$',
          tld: '.us',
          region: 'Americas',
          region_id: 2,
          subregion: 'Northern America',
          subregion_id: 3,
          nationality: 'American',
          timezones:
              'UTC-10:00,UTC-09:00,UTC-08:00,UTC-07:00,UTC-06:00,UTC-05:00,UTC-04:00',
          translations: 'json_data',
          latitude: '38.00000000',
          longitude: '-97.00000000',
          emojiU: 'U+1F1FA U+1F1F8');

      // Act
      final jsonMap = country.toJson();

      // Assert
      expect(jsonMap['id'], 101);
      expect(jsonMap['name'], 'United States');
      expect(jsonMap['iso2'], 'US');
      expect(jsonMap['iso3'], 'USA');
      expect(jsonMap['phonecode'], '1');
      expect(jsonMap['capital'], 'Washington D.C.');
      expect(jsonMap['currency'], 'USD');
      expect(jsonMap['native'], 'United States');
      expect(jsonMap['emoji'], '🇺🇸');
      expect(jsonMap['numeric_code'], '840');
      expect(jsonMap['currency_name'], 'United States dollar');
      expect(jsonMap['currency_symbol'], '\$');
      expect(jsonMap['tld'], '.us');
      expect(jsonMap['region'], 'Americas');
      expect(jsonMap['region_id'], 2);
      expect(jsonMap['subregion'], 'Northern America');
      expect(jsonMap['subregion_id'], 3);
      expect(jsonMap['nationality'], 'American');
      expect(jsonMap['timezones'],
          'UTC-10:00,UTC-09:00,UTC-08:00,UTC-07:00,UTC-06:00,UTC-05:00,UTC-04:00');
      expect(jsonMap['translations'], 'json_data');
      expect(jsonMap['latitude'], '38.00000000');
      expect(jsonMap['longitude'], '-97.00000000');
      expect(jsonMap['emojiU'], 'U+1F1FA U+1F1F8');
    });

    test('should handle null optional fields', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {'id': 101, 'name': 'United States'};

      // Act
      final result = Country.fromJson(jsonMap);

      // Assert
      expect(result.id, 101);
      expect(result.name, 'United States');
      expect(result.iso2, null);
      expect(result.iso3, null);
      expect(result.phonecode, null);
      expect(result.capital, null);
      expect(result.currency, null);
    });
  });
}
