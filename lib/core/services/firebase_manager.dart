import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:weather_app_assignment/firebase_options.dart';
import 'package:weather_app_assignment/core/services/secure_storage.dart';

class FirebaseManager {
  static final FirebaseManager _instance = FirebaseManager._internal();
  late final SecureStorage _secureStorage;

  factory FirebaseManager() {
    return _instance;
  }

  FirebaseManager._internal();

  void setSecureStorage(SecureStorage secureStorage) {
    _secureStorage = secureStorage;
  }

  Future<void> initialize() async {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    // Set default values
    await remoteConfig.setDefaults({
      'location_api_key': '',
      'weather_api_key': '',
    });

    // Fetch and activate remote config
    await remoteConfig.fetchAndActivate();

    // Store API keys in secure storage
    final locationApiKey = remoteConfig.getString('location_api_key');
    final weatherApiKey = remoteConfig.getString('weather_api_key');

    await _secureStorage.saveLocationApiKey(locationApiKey);
    await _secureStorage.saveWeatherApiKey(weatherApiKey);
  }

  Future<String> getLocationApiKey() async =>
      (await _secureStorage.getLocationApiKey()) ?? '';

  Future<String> getWeatherApiKey() async =>
      (await _secureStorage.getWeatherApiKey()) ?? '';
}
