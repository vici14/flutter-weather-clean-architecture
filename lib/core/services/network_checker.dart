import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkChecker {
  final InternetConnection _checker;
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;
  bool isInitialized = false;
  NetworkChecker(this._checker) {
    _initConnectionListener();
  }

  void _initConnectionListener() {
    _checker.onStatusChange.listen((status) {
      final hasConnection = status == InternetStatus.connected;
      _hasConnection = hasConnection;
      if (isInitialized) {
        _connectionStatusController.add(hasConnection);
      }
      isInitialized = true;
    });
  }

  Future<bool> checkConnection() async {
    final hasConnection = await _checker.hasInternetAccess;
    _hasConnection = hasConnection;
    return hasConnection;
  }

  void showConnectivityMessage(BuildContext context, bool isConnected) {
    final message =
        isConnected ? 'Internet connection restored' : 'No internet connection';

    final backgroundColor = isConnected ? Colors.green : Colors.red;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
