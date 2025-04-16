import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/dependency_injection/service_locator.dart';
import '../../../core/services/loading_manager.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/full_screen_loading.dart';
import '../../../data/repositories/i_weather_repository.dart';
import '../../location/bloc/location_bloc.dart';
import '../../location/bloc/location_state.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../../../core/widgets/error_screen.dart';
import '../../../core/base/screen/multi_bloc_base_screen.dart';
import '../../../core/base/bloc/base_bloc_state.dart';

class WeatherPage extends MultiProviderBlocScreen {
  const WeatherPage({
    Key? key,
  }) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends MultiProviderBlocScreenState<WeatherPage>
    with TickerProviderStateMixin {
  late AnimationController _todayForecastAnimationController;
  late AnimationController _fourDayForecastAnimationController;

  late WeatherBloc _weatherBloc;
  late LocationBloc _locationBloc;
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

    _weatherBloc = WeatherBloc(getIt<IWeatherRepository>());
    _locationBloc = getIt<LocationBloc>();
  }

  @override
  void dispose() {
    _todayForecastAnimationController.dispose();
    _fourDayForecastAnimationController.dispose();
    super.dispose();
  }

  @override
  List<BlocProvider> createProviders() {
    return [
      BlocProvider<WeatherBloc>.value(value: _weatherBloc),
      BlocProvider<LocationBloc>.value(value: _locationBloc),
    ];
  }

  @override
  List<StateAccessor> getStateAccessors(BuildContext context) {
    final locationBloc = context.read<LocationBloc>();
    return [
      StateAccessor(locationBloc),
      StateAccessor(_weatherBloc),
    ];
  }

  @override
  void initializeData(BuildContext context) {
    _fetchCountryDetails();
  }

  @override
  VoidCallback onRetry(BuildContext context) {
    _fetchCountryDetails();
    return () {};
  }

  void _fetchCountryDetails() {
    final locationBloc = context.read<LocationBloc>();
    if (locationBloc.state.selectedCountry != null) {
      locationBloc
          .getCountryDetails(locationBloc.state.selectedCountry?.iso2 ?? '');
    }
  }

  void _fetchWeatherData() {
    final locationBloc = context.read<LocationBloc>();

    if (locationBloc.state.countryDetails != null &&
        locationBloc.state.countryDetails!.latitude != null &&
        locationBloc.state.countryDetails!.longitude != null) {
      _weatherBloc.getWeatherForLocation(
        lat: double.parse(locationBloc.state.countryDetails!.latitude!),
        lon: double.parse(locationBloc.state.countryDetails!.longitude!),
      );
    }
  }

  @override
  void handleStateChange<B extends StateStreamable<S>, S extends BaseBlocState>(
      BuildContext context, B bloc, S state) {
    if (bloc is LocationBloc &&
        state is LocationState &&
        state.countryDetailsLoadingState.isLoadedSuccess) {
      _fetchWeatherData();
    }

    if (bloc is WeatherBloc &&
        state is WeatherState &&
        state.forecastLoadingState.isLoadedSuccess) {
      if (mounted) {
        _todayForecastAnimationController.forward();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _fourDayForecastAnimationController.forward();
          }
        });
      }
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    // Access states directly since we're already using BlocConsumer in the base class
    final locationState = context.read<LocationBloc>().state;
    final weatherState = context.read<WeatherBloc>().state;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(title: const Text('Weather Details'), elevation: 0),
      body: _buildContent(context, weatherState, locationState),
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
                weatherState.todayForecast != null
                    ? '${weatherState.todayForecast?.temp.avgTemp}°'
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
                  '${forecast.temp.avgTemp.round()} C',
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
