// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CountryImpl _$$CountryImplFromJson(Map<String, dynamic> json) =>
    _$CountryImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      iso2: json['iso2'] as String,
      iso3: json['iso3'] as String,
      phonecode: json['phonecode'] as String,
      capital: json['capital'] as String,
      currency: json['currency'] as String,
      native: json['native'] as String,
      emoji: json['emoji'] as String,
      numeric_code: json['numeric_code'] as String?,
      currency_name: json['currency_name'] as String?,
      currency_symbol: json['currency_symbol'] as String?,
      tld: json['tld'] as String?,
      region: json['region'] as String?,
      region_id: (json['region_id'] as num?)?.toInt(),
      subregion: json['subregion'] as String?,
      subregion_id: (json['subregion_id'] as num?)?.toInt(),
      nationality: json['nationality'] as String?,
      timezones: json['timezones'] as String?,
      translations: json['translations'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      emojiU: json['emojiU'] as String?,
    );

Map<String, dynamic> _$$CountryImplToJson(_$CountryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iso2': instance.iso2,
      'iso3': instance.iso3,
      'phonecode': instance.phonecode,
      'capital': instance.capital,
      'currency': instance.currency,
      'native': instance.native,
      'emoji': instance.emoji,
      'numeric_code': instance.numeric_code,
      'currency_name': instance.currency_name,
      'currency_symbol': instance.currency_symbol,
      'tld': instance.tld,
      'region': instance.region,
      'region_id': instance.region_id,
      'subregion': instance.subregion,
      'subregion_id': instance.subregion_id,
      'nationality': instance.nationality,
      'timezones': instance.timezones,
      'translations': instance.translations,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'emojiU': instance.emojiU,
    };
