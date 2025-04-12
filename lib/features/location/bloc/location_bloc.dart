import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app_assignment/core/error/AppError.dart';
import 'package:weather_app_assignment/data/models/city.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/data/models/state.dart';

import '../../../core/base/bloc/base_bloc.dart';
import '../../../core/base/bloc/loading_state.dart';
import '../../../data/repositories/i_location_repository.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends BaseBloc<LocationEvent, LocationState> {
  final ILocationRepository _locationRepository;

  LocationBloc(this._locationRepository) : super(state: const LocationState()) {
    on<GetCountriesEvent>(_onGetCountries);
    on<LoadStatesEvent>(_onLoadStates);
    on<LoadCitiesEvent>(_onLoadCities);
    on<SearchLocationsEvent>(_onSearchLocations);
    on<CountrySelectedEvent>(_onCountrySelected);
    on<StateSelectedEvent>(_onStateSelected);
    on<CitySelectedEvent>(_onCitySelected);
    on<ClearSelectionEvent>(_onClearSelection);
  }

  Future<void> _onGetCountries(
    GetCountriesEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(
      countriesLoadingState: LoadingState.loading(),
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));

    try {
      final result = await _locationRepository.getAllCountries();

      if (result.isSuccess && result.data != null) {
        emit(state.copyWith(
          countriesLoadingState: LoadingState<List<Country>>(
            isLoading: false,
            isLoadedSuccess: true,
            value: result.data,
          ),
          countries: result.data,
          allCountries: result.data,
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      } else {
        emit(state.copyWith(
          countriesLoadingState: LoadingState.error(
              AppError(message: 'Failed to load countries: ${result.error}')),
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        countriesLoadingState: LoadingState.error(
            AppError(message: 'Failed to load countries: ${e.toString()}')),
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  Future<void> _onLoadStates(
    LoadStatesEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(
      statesLoadingState: LoadingState.loading(),
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));

    try {
      final result =
          await _locationRepository.getStatesByCountry(event.countryIso2);

      if (result.isSuccess && result.data != null) {
        emit(state.copyWith(
          statesLoadingState: LoadingState<List<State>>(
            isLoading: false,
            isLoadedSuccess: true,
            value: result.data,
          ),
          states: result.data,
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      } else {
        emit(state.copyWith(
          statesLoadingState: LoadingState.error(
              AppError(message: 'Failed to load states: ${result.error}')),
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        statesLoadingState: LoadingState.error(
            AppError(message: 'Failed to load states: ${e.toString()}')),
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  Future<void> _onLoadCities(
    LoadCitiesEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(
      citiesLoadingState: LoadingState.loading(),
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));

    try {
      final result = await _locationRepository.getCitiesByStateAndCountry(
          event.countryIso2, event.stateIso2);

      if (result.isSuccess && result.data != null) {
        emit(state.copyWith(
          citiesLoadingState: LoadingState<List<City>>(
            isLoading: false,
            isLoadedSuccess: true,
            value: result.data,
          ),
          cities: result.data,
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      } else {
        emit(state.copyWith(
          citiesLoadingState: LoadingState.error(
              AppError(message: 'Failed to load cities: ${result.error}')),
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        citiesLoadingState: LoadingState.error(
            AppError(message: 'Failed to load cities: ${e.toString()}')),
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  Future<void> _onSearchLocations(
    SearchLocationsEvent event,
    Emitter<LocationState> emit,
  ) async {
    // Update loading state for search operation
    emit(state.copyWith(
      searchLoadingState: LoadingState.loading(),
      query: event.query,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));

    try {
      // If we have countries loaded, we can filter them locally
      if (state.allCountries.isNotEmpty) {
        List<Country> filteredCountries = [];

        // If query is empty, show all countries
        if (event.query.isEmpty) {
          filteredCountries = List.from(state.allCountries);
        } else {
          // Filter countries by name, capital, and region based on the query
          filteredCountries = state.allCountries
              .where((country) =>
                  country.name
                      .toLowerCase()
                      .contains(event.query.toLowerCase()) ||
                  (country.capital != null &&
                      country.capital!
                          .toLowerCase()
                          .contains(event.query.toLowerCase())) ||
                  (country.region != null &&
                      country.region!
                          .toLowerCase()
                          .contains(event.query.toLowerCase())))
              .toList();
        }

        // Update state with search results and success state
        emit(state.copyWith(
          countries: filteredCountries,
          searchLoadingState: LoadingState<List<Country>>(
            isLoading: false,
            isLoadedSuccess: true,
            value: filteredCountries,
          ),
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      } else {
        // If no countries loaded yet, set search state to error
        emit(state.copyWith(
          searchLoadingState: LoadingState.error(
            AppError(message: 'No countries available to search from.'),
          ),
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    } catch (e) {
      // Handle errors
      emit(state.copyWith(
        searchLoadingState: LoadingState.error(
          AppError(message: 'Failed to search locations: ${e.toString()}'),
        ),
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  void _onCountrySelected(
    CountrySelectedEvent event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(
      selectedCountry: event.country,
      clearSelectedState: true,
      clearSelectedCity: true,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));

    // Load states for the selected country
    add(LoadStatesEvent(event.country.iso2 ?? ''));
  }

  void _onStateSelected(
    StateSelectedEvent event,
    Emitter<LocationState> emit,
  ) {
    if (state.selectedCountry == null) return;

    emit(state.copyWith(
      selectedState: event.state,
      clearSelectedCity: true,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));

    // Load cities for the selected state and country
    add(LoadCitiesEvent(state.selectedCountry!.iso2 ?? '', event.state.iso2));
  }

  void _onCitySelected(
    CitySelectedEvent event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(
      selectedCity: event.city,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  void _onClearSelection(
    ClearSelectionEvent event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(
      clearSelectedCountry: event.clearCountry,
      clearSelectedState: event.clearState,
      clearSelectedCity: event.clearCity,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));

    // Reset related lists if needed
    if (event.clearCountry) {
      emit(state.copyWith(
        states: const [],
        cities: const [],
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    } else if (event.clearState) {
      emit(state.copyWith(
        cities: const [],
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  // Convenience methods for UI
  void onCountrySelected(Country country) {
    add(CountrySelectedEvent(country));
  }

  void onStateSelected(State state) {
    add(StateSelectedEvent(state));
  }

  void onCitySelected(City city) {
    add(CitySelectedEvent(city));
  }

  void loadCountries() {
    add(GetCountriesEvent());
  }

  void searchCountries(String query) {
    add(SearchLocationsEvent(query));
  }

  void clearSelections({
    bool clearCountry = false,
    bool clearState = false,
    bool clearCity = false,
  }) {
    add(ClearSelectionEvent(
      clearCountry: clearCountry,
      clearState: clearState,
      clearCity: clearCity,
    ));
  }
}
