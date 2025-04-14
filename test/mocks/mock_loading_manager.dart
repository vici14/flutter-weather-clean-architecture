import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';

class MockLoadingManager extends LoadingManager {
  MockLoadingManager() : super(GlobalKey<NavigatorState>());

  @override
  void showLoading() {}

  @override
  void hideLoading() {}

  @override
  void showLoadingWithMessage(String message) {}

  @override
  void forceHideLoading() {}

  @override
  void dispose() {}
}
