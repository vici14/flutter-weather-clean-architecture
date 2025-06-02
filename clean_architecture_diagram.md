# Flutter Weather App - Clean Architecture Flow Diagram

## Overall Architecture Overview
```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                PRESENTATION LAYER                                   │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                                   UI/Pages                                       │ │
│ │                    (lib/features/{feature}/pages/)                              │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                       ↕                                             │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                              BLoC/State Management                               │ │
│ │                    (lib/features/{feature}/bloc/)                               │ │
│ │                           extends BaseBloc                                      │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                       ↕                                             │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                                   Widgets                                        │ │
│ │                    (lib/features/{feature}/widgets/)                            │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                       ↕
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                  DOMAIN LAYER                                       │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                                  Use Cases                                       │ │
│ │                             (lib/domain/usecases/)                              │ │
│ │              GetWeatherForecastUseCase, GetCountriesUseCase                     │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                       ↕                                             │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                               Repository Contracts                               │ │
│ │                           (lib/domain/repositories/)                            │ │
│ │              IWeatherRepository, ILocationRepository                            │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                       ↕                                             │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                                   Entities                                       │ │
│ │                             (lib/domain/entities/)                              │ │
│ │                     WeatherEntity, CountryEntity                                │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                       ↕
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                   DATA LAYER                                        │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                             Repository Implementations                           │ │
│ │                             (lib/data/repositories/)                            │ │
│ │                     WeatherRepository, LocationRepository                       │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                       ↕                                             │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                                Data Services                                     │ │
│ │                              (lib/data/services/)                               │ │
│ │                           ServiceManager, API Client                            │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                       ↕                                             │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                                 Data Models                                      │ │
│ │                               (lib/data/models/)                                │ │
│ │                           DTOs, API Response Models                              │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
│                                       ↕                                             │
│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ │                              External Data Sources                               │ │
│ │                            REST APIs, Firebase, Storage                          │ │
│ └─────────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Detailed Call Flow Diagram

### 1. Dependency Injection Flow
```
main.dart
    ↓
AppInitializer
    ↓
setupServiceLocator() ← lib/core/dependency_injection/service_locator.dart
    ↓
┌─── Core Services Registration ───┐
│   • SecureStorage                │
│   • LoadingManager               │
│   • NetworkChecker               │
│   • FirebaseManager              │
│   • ServiceManager               │
└───────────────────────────────────┘
    ↓
┌─── Repository Registration ──────┐
│   • IWeatherRepository →         │
│     WeatherRepository            │
│   • ILocationRepository →        │
│     LocationRepository           │
└───────────────────────────────────┘
    ↓
┌─── Use Case Registration ────────┐
│   • GetWeatherForecastUseCase    │
│   • GetFourDaysForecastUseCase   │
│   • GetCountriesUseCase          │
│   • GetCountryDetailsUseCase     │
└───────────────────────────────────┘
    ↓
┌─── BLoC Registration ────────────┐
│   • LocationBloc                │
│   • WeatherBloc                 │
└───────────────────────────────────┘
    ↓
MyApp with MultiBlocProvider
```

### 2. Feature Flow - Weather Feature
```
Weather Page
    ↓
User Action (e.g., get weather)
    ↓
WeatherBloc.getWeatherForecast()
    ↓
WeatherBloc dispatches GetWeatherForecastEvent
    ↓
WeatherBloc._onGetWeatherForecast()
    ↓
GetFourDaysForecastUseCase.call()
    ↓
IWeatherRepository.getFourDaysForecast()
    ↓
WeatherRepository.getFourDaysForecast()
    ↓
ServiceManager.weatherService.getFourDaysForecast()
    ↓
HTTP API Call
    ↓
Raw JSON Response
    ↓
Data Models (DTOs)
    ↓
Mappers convert to Domain Entities
    ↓
WeatherEntity returned to Use Case
    ↓
LoadingState.success(WeatherEntity) emitted
    ↓
BlocBuilder rebuilds Weather UI
```

### 3. Feature Flow - Location Feature
```
Location Page
    ↓
User Action (e.g., search countries)
    ↓
LocationBloc.getCountries()
    ↓
LocationBloc dispatches GetCountriesEvent
    ↓
LocationBloc._onGetCountries()
    ↓
GetCountriesUseCase.call()
    ↓
ILocationRepository.getAllCountries()
    ↓
LocationRepository.getAllCountries()
    ↓
ServiceManager.locationService.getAllCountries()
    ↓
HTTP API Call
    ↓
Raw JSON Response
    ↓
Data Models (DTOs)
    ↓
Mappers convert to Domain Entities
    ↓
List<CountryEntity> returned to Use Case
    ↓
LoadingState.success(List<CountryEntity>) emitted
    ↓
BlocBuilder rebuilds Location UI
```

## Architecture Layers Interaction

### Core Components
```
┌─────────────────────────────────────┐
│            lib/core/                │
│                                     │
│  ┌─── base/ ──────────────────────┐ │
│  │ • BaseBloc                     │ │
│  │ • BaseEvent                    │ │
│  │ • BaseBlocState                │ │
│  │ • LoadingState                 │ │
│  └────────────────────────────────┘ │
│                                     │
│  ┌─── services/ ──────────────────┐ │
│  │ • LoadingManager               │ │
│  │ • NetworkChecker               │ │
│  │ • FirebaseManager              │ │
│  │ • SecureStorage                │ │
│  └────────────────────────────────┘ │
│                                     │
│  ┌─── dependency_injection/ ──────┐ │
│  │ • ServiceLocator (GetIt)       │ │
│  └────────────────────────────────┘ │
│                                     │
│  ┌─── theme/ ─────────────────────┐ │
│  │ • AppTheme                     │ │
│  │ • AppColors                    │ │
│  │ • AppTextStyles                │ │
│  └────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### State Management Pattern
```
Event (User Action)
    ↓
BLoC receives event
    ↓
BLoC calls Use Case
    ↓
Use Case calls Repository Interface
    ↓
Repository Implementation makes API call
    ↓
Data mapped to Domain Entity
    ↓
Result wrapped in LoadingState
    ↓
New State emitted
    ↓
UI rebuilds with BlocBuilder/BlocListener
```

### Error Handling Flow
```
API Error/Exception
    ↓
Repository catches error
    ↓
Error mapped to Domain Failure
    ↓
Use Case receives failure
    ↓
BLoC emits LoadingState.error()
    ↓
UI shows error state
    ↓
User can retry action
```

## Key Architectural Benefits

1. **Separation of Concerns**: Each layer has distinct responsibilities
2. **Dependency Inversion**: Higher layers depend on abstractions, not concretions
3. **Testability**: Each layer can be tested independently
4. **Maintainability**: Changes in one layer don't affect others
5. **Scalability**: Easy to add new features following the same pattern

## Data Flow Summary

- **Downward**: UI → BLoC → Use Case → Repository → API
- **Upward**: API Response → Entity → LoadingState → UI Update
- **Dependencies**: Injected via GetIt service locator
- **State**: Managed through BLoC pattern with LoadingState wrapper