import 'package:equatable/equatable.dart';

class CountryEntity extends Equatable {
  final int id;
  final String name;
  final String? iso2;
  final String? iso3;
  final String? phonecode;
  final String? capital;
  final String? currency;
  final String? native;
  final String? emoji;
  final String? numericCode;
  final String? currencyName;
  final String? currencySymbol;
  final String? tld;
  final String? region;
  final int? regionId;
  final String? subregion;
  final int? subregionId;
  final String? nationality;
  final String? timezones;
  final String? translations;
  final String? latitude;
  final String? longitude;
  final String? emojiU;

  const CountryEntity({
    required this.id,
    required this.name,
    this.iso2,
    this.iso3,
    this.phonecode,
    this.capital,
    this.currency,
    this.native,
    this.emoji,
    this.numericCode,
    this.currencyName,
    this.currencySymbol,
    this.tld,
    this.region,
    this.regionId,
    this.subregion,
    this.subregionId,
    this.nationality,
    this.timezones,
    this.translations,
    this.latitude,
    this.longitude,
    this.emojiU,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        iso2,
        iso3,
        phonecode,
        capital,
        currency,
        native,
        emoji,
        numericCode,
        currencyName,
        currencySymbol,
        tld,
        region,
        regionId,
        subregion,
        subregionId,
        nationality,
        timezones,
        translations,
        latitude,
        longitude,
        emojiU
      ];
}
