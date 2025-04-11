import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:weather_app_assignment/core/config/app_config.dart';
import 'package:weather_app_assignment/firebase_options.dart';

class FirebaseManager {
  static final FirebaseManager _instance = FirebaseManager._internal();

  factory FirebaseManager() {
    return _instance;
  }

  FirebaseManager._internal();

  String locationApiKey = '';
  String weatherApiKey = '';

  Future<void> initialize() async {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Skip fetching from Remote Config if in mock test mode
    if (AppConfig().isMockTest) {
      // Use default values for mock testing
      locationApiKey = 'mock_location_api_key';
      weatherApiKey = 'mock_weather_api_key';
      return;
    }

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

    // Store API keys
    locationApiKey = remoteConfig.getString('location_api_key');
    weatherApiKey = remoteConfig.getString('weather_api_key');
  }

  String getLocationApiKey() => locationApiKey;
  String getWeatherApiKey() => weatherApiKey;
}
