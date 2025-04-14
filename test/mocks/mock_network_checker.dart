import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather_app_assignment/core/services/network_checker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class MockNetworkChecker extends NetworkChecker {
  final _connectionStatusController = StreamController<bool>.broadcast();
  bool _hasConnection = true;
  bool _isInitialized = false;

  MockNetworkChecker() : super(InternetConnection());

  @override
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  @override
  bool get hasConnection => _hasConnection;

  @override
  Future<bool> checkConnection() async {
    return _hasConnection;
  }

  @override
  void showConnectivityMessage(BuildContext context, bool isConnected) {}

  @override
  void dispose() {
    _connectionStatusController.close();
  }

  void setConnectionStatus(bool isConnected) {
    _hasConnection = isConnected;
    if (_isInitialized) {
      _connectionStatusController.add(isConnected);
    }
  }

  void initialize() {
    _isInitialized = true;
    _connectionStatusController.add(_hasConnection);
  }
}
