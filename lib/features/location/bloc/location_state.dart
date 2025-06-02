import '../../../core/base/bloc/base_bloc_state.dart';
import '../../../core/base/bloc/loading_state.dart';
import '../../../data/models/country.dart';

class LocationState extends BaseBlocState {
  final LoadingState<List<Country>> countriesLoadingState;
  final LoadingState<List<Country>> searchLoadingState;
  final LoadingState<Country> countryDetailsLoadingState;

  final List<Country> countries;
  final List<Country> allCountries;
  final Country? countryDetails;

  final Country? selectedCountry;

  final String query;
  final String errorMessage;

  const LocationState({
    super.timeStamp = 1,
    this.countriesLoadingState = const LoadingState(),
    this.searchLoadingState = const LoadingState(),
    this.countryDetailsLoadingState = const LoadingState(),
    this.countries = const [],
    this.allCountries = const [],
    this.countryDetails,
    this.selectedCountry,
    this.query = '',
    this.errorMessage = '',
  });

  LocationState copyWith({
    int? timeStamp,
    String? baseError,
    LoadingState<List<Country>>? countriesLoadingState,
    LoadingState<List<Country>>? searchLoadingState,
    LoadingState<Country>? countryDetailsLoadingState,
    List<Country>? countries,
    List<Country>? allCountries,
    Country? countryDetails,
    Country? selectedCountry,
    String? query,
    String? errorMessage,
    bool? clearSelectedCountry,
    bool? clearSelectedState,
    bool? clearSelectedCity,
  }) {
    return LocationState(
      timeStamp: timeStamp ?? this.timeStamp,
      countriesLoadingState:
          countriesLoadingState ?? this.countriesLoadingState,
      searchLoadingState: searchLoadingState ?? this.searchLoadingState,
      countryDetailsLoadingState:
          countryDetailsLoadingState ?? this.countryDetailsLoadingState,
      countries: countries ?? this.countries,
      allCountries: allCountries ?? this.allCountries,
      countryDetails: countryDetails ?? this.countryDetails,
      selectedCountry: clearSelectedCountry == true
          ? null
          : selectedCountry ?? this.selectedCountry,
      query: query ?? this.query,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
        timeStamp,
        countriesLoadingState,
        searchLoadingState,
        countryDetailsLoadingState,
        countries,
        allCountries,
        countryDetails ??
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
        query,
        errorMessage
      ];

  @override
  bool get hasInitializeError =>
      (!countryDetailsLoadingState.isLoading &&
          countryDetailsLoadingState.loadError != null) ||
      (!countriesLoadingState.isLoading &&
          countriesLoadingState.loadError != null);

  @override
  bool get isInitialLoading =>
      countryDetailsLoadingState.isLoading || countriesLoadingState.isLoading;

  @override
  List<LoadingState> get loadingStates =>
      [countryDetailsLoadingState, countriesLoadingState];
}
