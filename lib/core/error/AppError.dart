import 'dart:io';

import 'package:flutter/services.dart';
import 'package:weather_app_assignment/data/exception/DataException.dart';

class AppError {
  String? title;
  String? message;
  String? errorCode;
  String? debugMessage;
  dynamic extraJson;
  bool isNetworkException = false;

  AppError({
    this.title,
    this.errorCode,
    this.message,
    this.extraJson,
    this.debugMessage,
    this.isNetworkException = false,
  });

  @override
  String toString() =>
      "title:${title}\nerrorMessage:${message}\nerrorCode:${errorCode}\ndebugMessage:${debugMessage}\nextraJson:${extraJson.toString()}";

  AppError.fromPlatformException(PlatformException platformException) {
    title = platformException.code;
    errorCode = platformException.code;
    message = platformException.message;
    extraJson = platformException.details;
  }

  AppError.fromDataException(DataException dataException) {
    title = dataException.code;
    errorCode = dataException.code;
    message = dataException.message;
    extraJson = dataException.extraJson;
  }
}
