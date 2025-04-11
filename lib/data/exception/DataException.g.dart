// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DataException.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataException _$DataExceptionFromJson(Map<String, dynamic> json) =>
    DataException(
      message: json['message'] as String?,
      title: json['title'] as String?,
      debugMessage: json['debugMessage'] as String?,
      extraJson: json['extraJson'],
      serverCode: json['serverCode'] as String?,
    )
      ..code = json['code'] as String?
      ..data = json['data'];

Map<String, dynamic> _$DataExceptionToJson(DataException instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'message': instance.message,
      'title': instance.title,
      'debugMessage': instance.debugMessage,
      'serverCode': instance.serverCode,
      'extraJson': instance.extraJson,
    };
