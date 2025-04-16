import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app_assignment/core/services/network_checker.dart';

class MockInternetConnection extends Mock implements InternetConnection {
  final StreamController<InternetStatus> _controller =
      StreamController<InternetStatus>.broadcast();

  @override
  Stream<InternetStatus> get onStatusChange => _controller.stream;

  void emitStatus(InternetStatus status) {
    _controller.add(status);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

@GenerateMocks([BuildContext, ScaffoldMessengerState])
void main() {
  late MockInternetConnection mockInternetConnection;
  late NetworkChecker networkChecker;

  setUp(() {
    mockInternetConnection = MockInternetConnection();
    networkChecker = NetworkChecker(mockInternetConnection);
  });

  tearDown(() {
    networkChecker.dispose();
    mockInternetConnection.dispose();
  });

  test('should initialize with default connection status', () {
    expect(networkChecker.isInitialized, false);
    expect(networkChecker.hasConnection, true); // Default value
  });

  test('should update connection status when internet status changes',
      () async {
    // Initial status should be true by default
    expect(networkChecker.hasConnection, true);

    // Listen to stream to capture changes
    final connectionStatusList = <bool>[];
    networkChecker.connectionStatus.listen(connectionStatusList.add);

    // Emit disconnected status
    mockInternetConnection.emitStatus(InternetStatus.disconnected);

    // Wait for stream to process
    await Future.delayed(Duration.zero);

    // Connection status should be updated and streamed
    expect(networkChecker.hasConnection, false);
    expect(networkChecker.isInitialized, true);

    // Emit connected status
    mockInternetConnection.emitStatus(InternetStatus.connected);

    // Wait for stream to process
    await Future.delayed(Duration.zero);

    // Connection status should be updated and streamed
    expect(networkChecker.hasConnection, true);

    // Check if all status changes were streamed
    expect(connectionStatusList, [false, true]);
  });

  test('checkConnection should return current connection status', () async {
    // Mock the hasInternetAccess getter
    when(mockInternetConnection.hasInternetAccess)
        .thenAnswer((_) async => false);

    // Check connection should return the value from InternetConnection
    final result = await networkChecker.checkConnection();

    expect(result, false);
    expect(networkChecker.hasConnection, false);
  });
}
