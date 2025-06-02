import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:weather_app_assignment/core/dependency_injection/service_locator.dart';
import 'package:weather_app_assignment/core/error/AppError.dart';
import 'package:weather_app_assignment/data/models/country.dart';
import 'package:weather_app_assignment/data/mappers/country_mapper.dart';
import 'package:weather_app_assignment/domain/usecases/location/get_countries_usecase.dart';
import 'package:weather_app_assignment/domain/usecases/location/get_country_details_usecase.dart';

import '../../../core/base/bloc/base_bloc.dart';
import '../../../core/base/bloc/loading_state.dart';
import '../../../core/services/loading_manager.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends BaseBloc<LocationEvent, LocationState> {
  final GetCountriesUseCase _getCountriesUseCase;
  final GetCountryDetailsUseCase _getCountryDetailsUseCase;

  LocationBloc({
    required GetCountriesUseCase getCountriesUseCase,
    required GetCountryDetailsUseCase getCountryDetailsUseCase,
  })  : _getCountriesUseCase = getCountriesUseCase,
        _getCountryDetailsUseCase = getCountryDetailsUseCase,
        super(state: const LocationState()) {
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
      final result = await _getCountriesUseCase();

      result.fold(
        (failure) {
          emit(state.copyWith(
            countriesLoadingState: LoadingState.error(
              AppError(message: failure.message),
            ),
            timeStamp: DateTime.now().millisecondsSinceEpoch,
          ));
        },
        (countryEntities) {
          final countries = CountryMapper.toModelList(countryEntities);

          emit(state.copyWith(
            countriesLoadingState: LoadingState<List<Country>>(
              isLoading: false,
              isLoadedSuccess: true,
              value: countries,
            ),
            countries: countries,
            allCountries: countries,
            timeStamp: DateTime.now().millisecondsSinceEpoch,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        countriesLoadingState: LoadingState.error(
          AppError(message: e.toString()),
        ),
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  Future<void> _onSearchLocations(
    SearchLocationsEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(
      searchLoadingState: LoadingState.loading(),
      query: event.query,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));

    try {
      if (state.allCountries.isNotEmpty) {
        List<Country> filteredCountries = [];

        if (event.query.isEmpty) {
          filteredCountries = List.from(state.allCountries);
        } else {
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
        emit(state.copyWith(
          searchLoadingState: LoadingState.error(
            AppError(message: 'No countries available to search from.'),
          ),
          timeStamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        searchLoadingState: LoadingState.error(
          AppError(message: e.toString()),
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
      final result = await _getCountryDetailsUseCase(
        GetCountryDetailsParams(iso2: event.iso2),
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            countryDetailsLoadingState: LoadingState.error(
              AppError(message: failure.message),
            ),
            timeStamp: DateTime.now().millisecondsSinceEpoch,
          ));
          getIt<LoadingManager>().hideLoading();
        },
        (countryEntity) {
          final country = CountryMapper.toModel(countryEntity);

          emit(state.copyWith(
            countryDetailsLoadingState: LoadingState<Country>(
              isLoading: false,
              isLoadedSuccess: true,
              value: country,
            ),
            countryDetails: country,
            timeStamp: DateTime.now().millisecondsSinceEpoch,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        countryDetailsLoadingState: LoadingState.error(
          AppError(message: e.toString()),
        ),
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  void getCountries() {
    add(GetCountriesEvent());
  }

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

  resetLoadCountryDetails() {
    emit(state.copyWith(
      countryDetailsLoadingState: LoadingState.initial(),
      timeStamp: DateTime.now().millisecondsSinceEpoch,
    ));
  }
}
