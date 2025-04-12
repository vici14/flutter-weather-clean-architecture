import 'package:freezed_annotation/freezed_annotation.dart';

part 'country.freezed.dart';
part 'country.g.dart';

@freezed
class Country with _$Country {
  const factory Country({
    required int id,
    required String name,
    String? iso2,
    String? iso3,
    String? phonecode,
    String? capital,
    String? currency,
    String? native,
    String? emoji,
    String? numeric_code,
    String? currency_name,
    String? currency_symbol,
    String? tld,
    String? region,
    int? region_id,
    String? subregion,
    int? subregion_id,
    String? nationality,
    String? timezones,
    String? translations,
    String? latitude,
    String? longitude,
    String? emojiU,
  }) = _Country;

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);
}
