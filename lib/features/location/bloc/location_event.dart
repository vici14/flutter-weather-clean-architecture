import 'package:weather_app_assignment/data/models/city.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/data/models/state.dart';

import '../../../core/base/bloc/base_event.dart';

abstract class LocationEvent extends BaseEvent {}

class LoadLocationsEvent extends LocationEvent {}

class LoadStatesEvent extends LocationEvent {
  final String countryIso2;

  LoadStatesEvent(this.countryIso2);
}

class LoadCitiesEvent extends LocationEvent {
  final String countryIso2;
  final String stateIso2;

  LoadCitiesEvent(this.countryIso2, this.stateIso2);
}

class SearchLocationsEvent extends LocationEvent {
  final String query;

  SearchLocationsEvent(this.query);
}

class CountrySelectedEvent extends LocationEvent {
  final Country country;

  CountrySelectedEvent(this.country);
}

class StateSelectedEvent extends LocationEvent {
  final State state;

  StateSelectedEvent(this.state);
}

class CitySelectedEvent extends LocationEvent {
  final City city;

  CitySelectedEvent(this.city);
}

class ClearSelectionEvent extends LocationEvent {
  final bool clearCountry;
  final bool clearState;
  final bool clearCity;

  ClearSelectionEvent({
    this.clearCountry = false,
    this.clearState = false,
    this.clearCity = false,
  });
}
