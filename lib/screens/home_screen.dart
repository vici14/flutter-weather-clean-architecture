import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../managers/location_manager.dart';
import '../routes/app_routes.dart';
import '../theme/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationManager _locationManager = LocationManager();
  late List<Location> _locations;
  late List<Location> _filteredLocations;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locations = _locationManager.getLocations();
    _filteredLocations = _locations;

    _searchController.addListener(() {
      _filterLocations(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations(String query) {
    setState(() {
      _filteredLocations = _locationManager.searchLocations(query);
    });
  }

  void _selectLocation(Location location) {
    Navigator.pushNamed(context, AppRoutes.weatherDetails, arguments: location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text('Select Location', style: AppTextStyles.cityNameStyle),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a city',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _filteredLocations.isEmpty
                        ? const Center(child: Text('No locations found'))
                        : ListView.separated(
                          itemCount: _filteredLocations.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final location = _filteredLocations[index];
                            return ListTile(
                              title: Text(location.name),
                              subtitle: Text(location.country),
                              onTap: () => _selectLocation(location),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
