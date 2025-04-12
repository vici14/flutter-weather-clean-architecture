import '../../../core/base/bloc/base_bloc_state.dart';
import '../../../core/base/bloc/loading_state.dart';
import '../../../data/models/city.dart';
import '../../../data/models/country.dart';
import '../../../data/models/state.dart';

class LocationState extends BaseBlocState {
  final LoadingState<List<Country>> countriesLoadingState;
  final LoadingState<List<State>> statesLoadingState;
  final LoadingState<List<City>> citiesLoadingState;
  final LoadingState<List<Country>> searchLoadingState;

  final List<Country> countries;
  final List<Country> allCountries; // Store the original list of countries
  final List<State> states;
  final List<City> cities;

  final Country? selectedCountry;
  final State? selectedState;
  final City? selectedCity;

  final String query;
  final String errorMessage;

  const LocationState({
    super.timeStamp = 1,
    super.baseError = '',
    this.countriesLoadingState = const LoadingState(),
    this.statesLoadingState = const LoadingState(),
    this.citiesLoadingState = const LoadingState(),
    this.searchLoadingState = const LoadingState(),
    this.countries = const [],
    this.allCountries = const [],
    this.states = const [],
    this.cities = const [],
    this.selectedCountry,
    this.selectedState,
    this.selectedCity,
    this.query = '',
    this.errorMessage = '',
  });

  LocationState copyWith({
    int? timeStamp,
    String? baseError,
    LoadingState<List<Country>>? countriesLoadingState,
    LoadingState<List<State>>? statesLoadingState,
    LoadingState<List<City>>? citiesLoadingState,
    LoadingState<List<Country>>? searchLoadingState,
    List<Country>? countries,
    List<Country>? allCountries,
    List<State>? states,
    List<City>? cities,
    Country? selectedCountry,
    State? selectedState,
    City? selectedCity,
    String? query,
    String? errorMessage,
    bool? clearSelectedCountry,
    bool? clearSelectedState,
    bool? clearSelectedCity,
  }) {
    return LocationState(
      timeStamp: timeStamp ?? this.timeStamp,
      baseError: baseError ?? this.baseError,
      countriesLoadingState:
          countriesLoadingState ?? this.countriesLoadingState,
      statesLoadingState: statesLoadingState ?? this.statesLoadingState,
      citiesLoadingState: citiesLoadingState ?? this.citiesLoadingState,
      searchLoadingState: searchLoadingState ?? this.searchLoadingState,
      countries: countries ?? this.countries,
      allCountries: allCountries ?? this.allCountries,
      states: states ?? this.states,
      cities: cities ?? this.cities,
      selectedCountry: clearSelectedCountry == true
          ? null
          : selectedCountry ?? this.selectedCountry,
      selectedState: clearSelectedState == true
          ? null
          : selectedState ?? this.selectedState,
      selectedCity:
          clearSelectedCity == true ? null : selectedCity ?? this.selectedCity,
      query: query ?? this.query,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
        timeStamp,
        countriesLoadingState,
        statesLoadingState,
        citiesLoadingState,
        searchLoadingState,
        countries,
        allCountries,
        states,
        cities,
        selectedCountry ??
            const Country(
                id: 0,
                name: '',
                iso2: '',
                iso3: '',
                phonecode: '',
                capital: '',
                currency: '',
                native: '',
                emoji: ''),
        selectedState ??
            const State(
                id: 0,
                name: '',
                country_id: 0,
                country_code: '',
                iso2: '',
                type: ''),
        selectedCity ??
            const City(
                id: 0,
                name: '',
                state_id: 0,
                state_code: '',
                country_id: 0,
                country_code: ''),
        query,
        errorMessage
      ];
}
