import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/location_model.dart';

class WeatherScreen extends StatelessWidget {
  final Location? location;

  const WeatherScreen({Key? key, this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Location locationData =
        location ??
        ModalRoute.of(context)?.settings.arguments as Location? ??
        Location(id: 'default', name: 'Bangalore', country: 'India');

    return Scaffold(
      appBar: AppBar(title: const Text('Weather Details'), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Center(child: Text('20°', style: AppTextStyles.temperatureStyle)),
              Center(
                child: Text(
                  locationData.fullName,
                  style: AppTextStyles.cityNameStyle,
                ),
              ),
              const SizedBox(height: 48),
              _buildForecastItem(context, 'Tuesday', '24 C'),
              const Divider(),
              _buildForecastItem(context, 'Wednesday', '21 C'),
              const Divider(),
              _buildForecastItem(context, 'Thursday', '28 C'),
              const Divider(),
              _buildForecastItem(context, 'Friday', '26 C'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForecastItem(
    BuildContext context,
    String day,
    String temperature,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: AppTextStyles.dayForecastStyle),
          Text(temperature, style: AppTextStyles.tempForecastStyle),
        ],
      ),
    );
  }
}
