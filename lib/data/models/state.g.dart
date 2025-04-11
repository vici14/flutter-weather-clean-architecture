// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StateImpl _$$StateImplFromJson(Map<String, dynamic> json) => _$StateImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      country_id: (json['country_id'] as num).toInt(),
      country_code: json['country_code'] as String,
      iso2: json['iso2'] as String,
      type: json['type'] as String,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
    );

Map<String, dynamic> _$$StateImplToJson(_$StateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country_id': instance.country_id,
      'country_code': instance.country_code,
      'iso2': instance.iso2,
      'type': instance.type,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
