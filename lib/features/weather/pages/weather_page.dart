import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/dependency_injection/service_locator.dart';
import '../../../core/services/loading_manager.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/full_screen_loading.dart';
import '../../location/bloc/location_bloc.dart';
import '../../location/bloc/location_state.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../../../core/widgets/error_screen.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({
    Key? key,
  }) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with TickerProviderStateMixin {
  late AnimationController _todayForecastAnimationController;
  late AnimationController _fourDayForecastAnimationController;

  @override
  void initState() {
    super.initState();

    // Setup animation controllers
    _todayForecastAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fourDayForecastAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fetchCountryDetails();
  }

  @override
  void dispose() {
    _todayForecastAnimationController.dispose();
    _fourDayForecastAnimationController.dispose();
    super.dispose();
  }

  void _fetchCountryDetails() {
    final locationBloc = context.read<LocationBloc>();
    if (locationBloc.state.selectedCountry != null) {
      locationBloc
          .getCountryDetails(locationBloc.state.selectedCountry?.iso2 ?? '');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<LoadingManager>().showLoading();
    });
  }

  void _fetchWeatherData() {
    final weatherBloc = context.read<WeatherBloc>();
    final locationBloc = context.read<LocationBloc>();

    if (locationBloc.state.countryDetails != null &&
        locationBloc.state.countryDetails!.latitude != null &&
        locationBloc.state.countryDetails!.longitude != null) {
      weatherBloc.getWeatherForLocation(
        lat: double.parse(locationBloc.state.countryDetails!.latitude!),
        lon: double.parse(locationBloc.state.countryDetails!.longitude!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationBloc, LocationState>(
      listenWhen: (previous, current) =>
          previous.countryDetailsLoadingState !=
          current.countryDetailsLoadingState,
      listener: (context, locationState) {
        if (locationState.countryDetailsLoadingState.isLoadedSuccess) {
          _fetchWeatherData();
        }
      },
      builder: (context, locationState) {
        return BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, weatherState) {
            if (weatherState.forecastLoadingState.loadError != null) {
              return ErrorScreen(
                onRetry: _fetchCountryDetails,
              );
            }

            return StreamBuilder<LoadingStatus>(
              stream: getIt<LoadingManager>().loadingStream,
              builder: (context, snapshot) {
                // Only trigger animations when loading completes AND we have no errors
                if (snapshot.data == LoadingStatus.completed &&
                    weatherState.forecastLoadingState.loadError == null) {
                  if (mounted) {
                    _todayForecastAnimationController.forward();
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        _fourDayForecastAnimationController.forward();
                      }
                    });
                  }
                }

                return Scaffold(
                  backgroundColor: AppColors.appBackground,
                  appBar: AppBar(
                      title: const Text('Weather Details'), elevation: 0),
                  body: _buildContent(context, weatherState, locationState),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, WeatherState weatherState,
      LocationState locationState) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 56),
              _buildAnimatedTodayForecast(context, weatherState, locationState),
            ],
          ),
          Column(
            children: [
              const SizedBox(height: 62),
              _buildAnimatedFourDaysAheadForecast(context, weatherState)
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAnimatedTodayForecast(BuildContext context,
      WeatherState weatherState, LocationState locationState) {
    return FadeTransition(
      opacity: _todayForecastAnimationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _todayForecastAnimationController,
          curve: Curves.easeOut,
        )),
        child: _buildTodayForecast(context, weatherState, locationState),
      ),
    );
  }

  Widget _buildAnimatedFourDaysAheadForecast(
      BuildContext context, WeatherState weatherState) {
    return FadeTransition(
      opacity: _fourDayForecastAnimationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _fourDayForecastAnimationController,
          curve: Curves.easeOut,
        )),
        child: _buildFourDaysAHeadForecast(context, weatherState),
      ),
    );
  }

  Widget _buildTodayForecast(BuildContext context, WeatherState weatherState,
      LocationState locationState) {
    return Column(
      children: [
        Center(
            child: Text(
                weatherState.forecast.isNotEmpty
                    ? '${weatherState.forecast.first.temp.day.round()}°'
                    : '--°',
                style: AppTextStyles.temperatureStyle)),
        Center(
          child: Text(
            locationState.countryDetails?.name ??
                locationState.selectedCountry?.name ??
                'Loading...',
            style: AppTextStyles.cityNameStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildFourDaysAHeadForecast(
      BuildContext context, WeatherState weatherState) {
    return weatherState.forecast.isEmpty
        ? const Center(child: Text('No forecast data available'))
        : Container(
            padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(0, 4))
            ], color: Colors.white),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: weatherState.forecast.isEmpty
                  ? 0
                  : weatherState.forecast.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                if (index >= weatherState.forecast.length) {
                  return const SizedBox();
                }

                final forecast = weatherState.forecast[index];
                final day = _getDayName(
                    DateTime.fromMillisecondsSinceEpoch(forecast.dt * 1000));
                return _buildForecastItem(
                  context,
                  day,
                  '${forecast.temp.day.round()} C',
                );
              },
            ),
          );
  }

  String _getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  Widget _buildForecastItem(
    BuildContext context,
    String day,
    String temperature,
  ) {
    return Container(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(day, style: AppTextStyles.dayForecastStyle),
            Text(temperature, style: AppTextStyles.tempForecastStyle),
          ],
        ),
      ),
    );
  }
}
