class LocationData {
  final String lat;
  final String long;
  final String name;
  const LocationData({required this.lat, required this.long, required this.name });

  num get latitude => num.tryParse(lat) ?? 0;
  num get longitude => num.tryParse(long) ?? 0;
}
