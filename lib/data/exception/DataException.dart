 import 'package:json_annotation/json_annotation.dart';

import 'BaseApiErrorResponse.dart';

part 'DataException.g.dart';

@JsonSerializable()
class DataException extends BaseApiErrorResponse {
  final String? message;
  final String? title;
  final String? debugMessage;
  final String? serverCode;
  final dynamic extraJson;

  DataException(
      {this.message,
      this.title,
      this.debugMessage,
      this.extraJson,
      this.serverCode});

  @override
  String toString() {
    return '$runtimeType: {statusCode: $code, serverCode: $serverCode},'
        ' message: $message, title: $title, debugMessage: $debugMessage, '
        'extraJson: ${extraJson.toString()}';
  }

  static const fromJsonFactory = _$DataExceptionFromJson;

  Map<String, dynamic> toJson() => _$DataExceptionToJson(this);

  //Network case
}
