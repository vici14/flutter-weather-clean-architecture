import 'package:json_annotation/json_annotation.dart';

part 'BaseApiErrorResponse.g.dart';

@JsonSerializable()
class BaseApiErrorResponse {
  String? code;
  String? message;
  dynamic data;

  static const fromJsonFactory = _$BaseApiErrorResponseFromJson;

  Map<String, dynamic> toJson() => _$BaseApiErrorResponseToJson(this);
}
