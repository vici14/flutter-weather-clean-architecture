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

    // You can add additional error reporting here (e.g., to Sentry, Firebase Crashlytics)
  };

  // Setup dependency injection
  await setupServiceLocator();

  runApp(const MyApp());
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
      }
    });
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