// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CityImpl _$$CityImplFromJson(Map<String, dynamic> json) => _$CityImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      state_id: (json['state_id'] as num).toInt(),
      state_code: json['state_code'] as String,
      country_id: (json['country_id'] as num).toInt(),
      country_code: json['country_code'] as String,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
    );

Map<String, dynamic> _$$CityImplToJson(_$CityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'state_id': instance.state_id,
      'state_code': instance.state_code,
      'country_id': instance.country_id,
      'country_code': instance.country_code,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
