import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app_assignment/features/weather/bloc/weather_bloc.dart';
import 'core/theme/theme.dart';
import 'features/location/bloc/location_bloc.dart';
import 'routes/app_routes.dart';
import 'core/dependency_injection/service_locator.dart';
import 'core/services/loading_manager.dart';
import 'core/services/network_checker.dart';
import 'core/widgets/network_error_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup bloc observer
  Bloc.observer = AppBlocObserver();

  // Handle Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      print('Flutter error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    }
  };

  // We'll run the app with a wrapper that handles initialization errors
  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<bool> _initializationFuture;
  String _errorMessage = 'Failed to initialize app dependencies.';

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  Future<bool> _initializeApp() async {
    try {
      final result = await setupServiceLocator();
      if (!result) {
        _errorMessage = 'Network error. Unable to initialize app dependencies.';
      }
      return result;
    } catch (e) {
      _errorMessage = 'An error occurred during app initialization.';
      print('Initialization error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _initializationFuture,
        builder: (context, snapshot) {
          // Still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Error or failed initialization
          if (snapshot.hasError || (snapshot.hasData && !snapshot.data!)) {
            return NetworkErrorScreen(
              onRetry: () {
                setState(() {
                  _initializationFuture = _initializeApp();
                });
              },
              message: _errorMessage,
            );
          }

          // Successfully initialized
          return const MyApp();
        },
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late NetworkChecker _networkChecker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _networkChecker = getIt<NetworkChecker>();
    _listenToNetworkChanges();
  }

  void _listenToNetworkChanges() {
    _networkChecker.connectionStatus.listen((isConnected) {
      if (navigatorKey.currentContext != null) {
        _networkChecker.showConnectivityMessage(
            navigatorKey.currentContext!, isConnected);

        // Try to retry service initialization when network is restored
        if (isConnected) {
          _retryInitialization();
        }
      }
    });
  }

  Future<void> _retryInitialization() async {
    // Retry service initialization when network is available
    await retryServiceInitialization();
  }

  @override
  void dispose() {
    // Dispose resources when app is shut down
    WidgetsBinding.instance.removeObserver(this);
    getIt<LoadingManager>().dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationBloc>.value(
          value: getIt<LocationBloc>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Weather App',
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.home,
        debugShowCheckedModeBanner: !kReleaseMode,
      ),
    );
  }
}

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      // print('${bloc.runtimeType} $change');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('${bloc.runtimeType} $error $stackTrace');
    }
    super.onError(bloc, error, stackTrace);
  }
}
