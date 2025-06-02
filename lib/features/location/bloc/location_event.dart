import '../../../data/models/country.dart';
import '../../../core/base/bloc/base_event.dart';

abstract class LocationEvent extends BaseEvent {}

class GetCountriesEvent extends LocationEvent {}

class SearchLocationsEvent extends LocationEvent {
  final String query;

  SearchLocationsEvent(this.query);
}

class CountrySelectedEvent extends LocationEvent {
  final Country country;

  CountrySelectedEvent(this.country);
}

class GetCountryDetailsEvent extends LocationEvent {
  final String iso2;

  GetCountryDetailsEvent(this.iso2);
}

class ClearSelectionEvent extends LocationEvent {
  final bool clearCountry;

  ClearSelectionEvent({
    this.clearCountry = false,
  });
}
