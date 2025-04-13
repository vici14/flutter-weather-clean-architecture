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
    on<SearchLocationsEvent>(_onSearchLocations);
    on<CountrySelectedEvent>(_onCountrySelected);
    on<ClearSelectionEvent>(_onClearSelection);
    on<GetCountryDetailsEvent>(_onGetCountryDetails);
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
  }

  void _onClearSelection(
    ClearSelectionEvent event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(
      clearSelectedCountry: event.clearCountry,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));

    // Reset related lists if needed
    if (event.clearCountry) {
      emit(state.copyWith(
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  Future<void> _onGetCountryDetails(
    GetCountryDetailsEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(
      countryDetailsLoadingState: LoadingState.loading(),
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));

    try {
      final result = await _locationRepository.getCountryDetails(event.iso2);

      if (result.isSuccess && result.data != null) {
        emit(state.copyWith(
          countryDetailsLoadingState: LoadingState<Country>(
            isLoading: false,
            isLoadedSuccess: true,
            value: result.data,
          ),
          countryDetails: result.data,
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      } else {
        emit(state.copyWith(
          countryDetailsLoadingState: LoadingState.error(
            AppError(
                message: 'Failed to load country details: ${result.error}'),
          ),
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        countryDetailsLoadingState: LoadingState.error(
          AppError(message: 'Failed to load country details: ${e.toString()}'),
        ),
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }
  void getCountries() {
    add(GetCountriesEvent());
  }

  // Convenience methods for UI
  void onCountrySelected(Country country) {
    add(CountrySelectedEvent(country));
  }

  void getCountryDetails(String iso2) {
    add(GetCountryDetailsEvent(iso2));
  }

  void searchCountries(String query) {
    add(SearchLocationsEvent(query));
  }

  void clearSelections({
    bool clearCountry = false,
  }) {
    add(ClearSelectionEvent(
      clearCountry: clearCountry,
    ));
  }
}
