import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:weather_app_assignment/firebase_options.dart';
import 'package:weather_app_assignment/core/services/secure_storage.dart';

class FirebaseManager {
  static final FirebaseManager _instance = FirebaseManager._internal();
  late final SecureStorage _secureStorage;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool _isSecureStorageSet = false;
  bool _isTestMode = false;

  factory FirebaseManager() {
    return _instance;
  }

  FirebaseManager._internal();

  void setSecureStorage(SecureStorage secureStorage) {
    if (!_isSecureStorageSet) {
      _secureStorage = secureStorage;
      _isSecureStorageSet = true;
    }
  }

  /// Set test mode for unit testing purposes
  /// When in test mode, Firebase initialization is skipped
  void setTestMode(bool isTestMode) {
    _isTestMode = isTestMode;
    if (isTestMode) {
      // Auto-mark as initialized in test mode
      _isInitialized = true;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Skip actual Firebase initialization in test mode
    if (_isTestMode) {
      _isInitialized = true;
      return;
    }

    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Firebase Remote Config
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 5),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values
      await remoteConfig.setDefaults({
        'location_api_key': '',
        'weather_api_key': '',
      });

      try {
        // Try to fetch and activate remote config
        await remoteConfig.fetchAndActivate().timeout(
              const Duration(seconds: 3),
              onTimeout: () =>
                  throw TimeoutException('Remote config fetch timed out'),
            );

        // Store API keys in secure storage
        final locationApiKey = remoteConfig.getString('location_api_key');
        final weatherApiKey = remoteConfig.getString('weather_api_key');

        await _secureStorage.saveLocationApiKey(locationApiKey);
        await _secureStorage.saveWeatherApiKey(weatherApiKey);
      } catch (e) {
        debugPrint('Firebase Remote Config fetch failed: $e');
        // Continue with cached values if available
        try {
          // Try to get cached values without fetching
          final locationApiKey = remoteConfig.getString('location_api_key');
          final weatherApiKey = remoteConfig.getString('weather_api_key');

          // Only save if we have cached values
          if (locationApiKey.isNotEmpty) {
            await _secureStorage.saveLocationApiKey(locationApiKey);
          }

          if (weatherApiKey.isNotEmpty) {
            await _secureStorage.saveWeatherApiKey(weatherApiKey);
          }
        } catch (innerError) {
          debugPrint('Failed to get cached remote config: $innerError');
          // Just continue with empty values
        }
      }

      _isInitialized = true;
    } catch (e) {
      // Firebase initialization failed, but we don't want to crash the app
      debugPrint('Firebase initialization error: $e');
      // Mark as not initialized so we can retry later
      _isInitialized = false;
      // Rethrow network related errors so they can be handled at a higher level
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('network')) {
        throw e;
      }
    }
  }

  Future<bool> retry() async {
    if (_isInitialized) return true;
    if (_isTestMode) return true;

    try {
      await initialize();
      return _isInitialized;
    } catch (e) {
      debugPrint('Firebase retry failed: $e');
      return false;
    }
  }

  Future<String> getLocationApiKey() async =>
      (await _secureStorage.getLocationApiKey()) ?? '';

  Future<String> getWeatherApiKey() async =>
      (await _secureStorage.getWeatherApiKey()) ?? '';
}
