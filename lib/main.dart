import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app_assignment/features/weather/bloc/weather_bloc.dart';
import 'core/theme/theme.dart';
import 'features/location/bloc/location_bloc.dart';
import 'routes/app_routes.dart';
import 'core/dependency_injection/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationBloc>(
          create: (context) => getIt<LocationBloc>(),
        ),
        BlocProvider<WeatherBloc>(
          create: (context) => getIt<WeatherBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Weather App',
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.home,
        debugShowCheckedModeBanner: !kReleaseMode,
      ),
    );
  }
}
