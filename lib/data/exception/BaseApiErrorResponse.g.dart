// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BaseApiErrorResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseApiErrorResponse _$BaseApiErrorResponseFromJson(
        Map<String, dynamic> json) =>
    BaseApiErrorResponse()
      ..code = json['code'] as String?
      ..message = json['message'] as String?
      ..data = json['data'];

Map<String, dynamic> _$BaseApiErrorResponseToJson(
        BaseApiErrorResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
