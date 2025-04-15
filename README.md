# Weather App

A modern Flutter application that provides real-time weather information based on location. This app demonstrates clean architecture principles, state management with BLoC pattern, and robust error handling.

## Features

- View a comprehensive list of countries with search functionality
- Get detailed weather conditions for selected countries
- Current day plus 4-day weather forecast with daily temperature information
- Location-based weather data with smooth animations
- Network connectivity handling with automatic retry
- Error recovery and user-friendly error states

### Main Screens

#### Home Screen (Countries List)
The app features a clean home screen that displays a list of countries fetched from [CountryStateCity API](https://countrystatecity.in/docs/). This screen includes:
- Fast search functionality to filter countries
- Animated search bar that pins to the top when scrolling
- Efficient list rendering with proper error handling
- Network state monitoring to handle connectivity issues

#### Weather Details Screen
When a country is selected, the app displays detailed weather information fetched from [OpenWeatherMap API](https://openweathermap.org/) using the country's latitude and longitude. This screen includes:
- Current temperature with location name
- Current day plus 4-day weather forecast with daily temperatures
- Beautiful animations for weather data presentation
- Clean and intuitive interface for weather information

## Project Architecture

This project follows Clean Architecture principles with a BLoC pattern for state management:

```
lib/
  ├── core/              # App-wide utilities, constants, and reusable components
  │   ├── constants/     # App-wide constants
  │   ├── dependency_injection/ # Service locator for DI
  │   ├── services/      # Core services (network, storage, etc.)
  │   ├── theme/         # Theme configuration
  │   ├── utils/         # Helper functions and extensions
  │   └── widgets/       # Reusable widgets
  ├── data/              # Data layer
  │   ├── models/        # Data models/DTOs
  │   ├── repositories/  # Repository implementations
  │   └── services/      # API services
  ├── features/          # Feature modules
  │   ├── location/      # Location feature
  │   │   ├── bloc/      # State management
  │   │   ├── pages/     # UI screens
  │   │   └── widgets/   # Feature-specific widgets
  │   └── weather/       # Weather feature (similar structure)
  ├── routes/            # App navigation
  └── main.dart          # Entry point
```

## Technical Approach

### State Management

The app uses the BLoC (Business Logic Component) pattern with flutter_bloc package to separate business logic from UI. Each feature has its own BLoC that manages the feature's state and handles user events.

```
Feature
  ├── Events    # User actions
  ├── States    # UI states
  └── Bloc      # Business logic
```

### Bloc Architecture Enhancements

The app implements an enhanced Bloc architecture with the `MultiProviderBlocScreen` base class that provides:

- Coordinated loading states across multiple BLoCs
- Standardized error handling and recovery
- Type-safe state management with `StateAccessor`
- Automatic loading state coordination through `BlocLoadingCoordinator`
- Clear separation between UI and state handling logic

For detailed implementation and architecture documentation, see [Multi Bloc Base Screen Documentation](docs/multi_bloc_base_screen_documentation.md).

### Dependency Injection

GetIt is used as a service locator to manage dependencies. This approach allows for:
- Loose coupling between components
- Easier testing through dependency substitution
- Singleton management for services

### Network Handling

The app implements robust network connectivity checking:
- Initial connectivity check during app startup
- Continuous monitoring with Internet Connection Checker
- User notifications via Scaffold messages
- Automatic retry mechanisms when connectivity is restored

### Error Handling

The app implements a comprehensive error handling architecture using a multi-layered approach:

#### Data Layer
- Uses `DataException` for standardizing API and data-related errors
- JSON serializable exceptions with detailed error information
- Custom handling for different HTTP status codes and Dio exceptions
- Network-specific error handling via `NetworkErrorHandler` utility

### Data Layer Architecture

The app implements a robust data layer with specialized components for API communication:

#### Service Manager
A singleton class that manages and coordinates all API services:
- Centralizes initialization of service instances with API keys
- Provides fallback mechanisms for uninitialized services
- Handles proper resource disposal when services are no longer needed
- Acts as a factory for obtaining service instances with proper configurations

#### API Client
Lightweight wrapper around Dio HTTP client for consistent API communication:
- Simplifies HTTP request handling with structured interfaces
- Supports custom interceptors for request/response processing
- Provides easy-to-use methods for common HTTP operations
- Handles proper resource closure to prevent memory leaks

#### Interceptors Architecture
The app uses a multi-layered interceptor system to process API requests and responses:
- **LoggingInterceptor**: Captures detailed request/response information for debugging
- **LocationInterceptor**: Handles location service-specific request/response processing
- **WeatherInterceptor**: Provides weather service-specific request/response handling

#### API Services
Specialized service classes for different API endpoints:
- **LocationService**: Communicates with CountryStateCity API
  - Fetches country information with appropriate headers and authentication
  - Transforms raw API responses into domain models
  - Handles service-specific error cases with proper error context
  
- **WeatherService**: Interacts with OpenWeatherMap API
  - Retrieves weather forecasts based on geographical coordinates
  - Supports configuration options like units (metric/imperial)
  - Provides specialized methods for daily forecasts
  - Maps API responses to strongly-typed domain models

#### Error Handling System
Comprehensive error handling system in the data layer:
- **DataException**: Base exception type for all data-related errors
- **BaseApiErrorResponse**: JSON-serializable error representation
- **NetworkErrorHandler**: Utility for transforming Dio and HTTP errors
  - Maps HTTP status codes to meaningful exceptions
  - Handles network-specific error cases (timeouts, connection issues)
  - Provides consistent error responses with debug information

#### Functional Error Handling
Leverages fpdart's Either<Left, Right> pattern for robust error handling:
- Returns Either<DataException, T> from all repository methods
- Left side represents errors/failures
- Right side contains successful results
- Enables functional-style error propagation without exceptions
- Enforces error handling at the call site

#### Domain Layer
- Repository layer using Either<Failure, Success> pattern from fpdart
- Clear separation between data layer exceptions and domain layer failures
- Categorized error types for consistent handling across the application

#### Presentation Layer
- UI error states with user-friendly messages using `AppError` class
- Contextual error messages based on error category and type
- Automatic retry mechanisms for transient errors like network connectivity issues
- Comprehensive error logging for debugging and analytics

#### Error Handling Utilities
- Centralized `ErrorHandler` for consistent error mapping and categorization
- Error categorization system for analytics and reporting
- User-friendly message generation based on error categories
- Support for various error types (network, timeout, authentication, etc.)

## Environment Setup

### Current Environment

- Flutter: 3.29.2 (channel stable)
- Dart: 3.7.2
- OS: macOS 14.4.1 (darwin-arm64)
- Android SDK: 35.0.0
- Java: OpenJDK Runtime Environment (build 17.0.10+0-17.0.10b1087.21-11572160)

### Requirements

- Flutter SDK: 3.29.2 or higher
- Dart SDK: 3.7.2 or higher
- JDK: OpenJDK Runtime Environment (build 17.0.10+0-17.0.10b1087.21-11572160)
- Xcode: Latest version (for iOS development)
- Android Studio/VS Code with Flutter plugins
- Cocoapod: 1.16.2

### Minimum Platform Versions

- iOS: 12.0+
- Android: SDK 24+ 

### Compatible Devices

The app has been tested and confirmed to work on:

- Android emulator (Android 15 API 35)
- iOS simulator (ios 12+)
- macOS (14.4.1)
- Chrome (web)

## Getting Started

1. Clone the repository
2. Install dependencies:

```bash
flutter pub get
```

3. Generate necessary files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the application:

```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For macOS
flutter run -d macos

# For web
flutter run -d chrome
```

## Development Workflow

The project includes a helper script `flutter_dev.sh` with various commands:

```bash
# Get dependencies
./flutter_dev.sh get

# Clean project and get dependencies
./flutter_dev.sh pub-get

# Generate code with build_runner
./flutter_dev.sh build

# Run code generator in watch mode
./flutter_dev.sh watch

# Format code
./flutter_dev.sh format

# Run tests
./flutter_dev.sh test

# Build release APK
./flutter_dev.sh build-apk

# Build for iOS
./flutter_dev.sh build-ios
```

## Dependencies

The app uses several key packages:

- **State Management**
  - flutter_bloc: 9.1.0
  - equatable: 2.0.7

- **Dependency Injection**
  - get_it: 8.0.3

- **Network**
  - dio: 5.8.0+1
  - http: 1.3.0
  - internet_connection_checker_plus: 2.7.1

- **Storage**
  - flutter_secure_storage: 9.2.4

- **Firebase**
  - firebase_core: 2.32.0
  - firebase_remote_config: 4.4.7

- **Functional Programming**
  - fpdart: 1.1.1

- **UI**
  - google_fonts: 6.2.1

- **Testing**
  - bloc_test: 10.0.0
  - mockito: 5.4.5
  - integration_test (Flutter SDK)

- **Code Generation**
  - freezed: 2.5.8
  - json_serializable: 6.9.4
  - build_runner: 2.4.15

## Project Initialization

The app initializes in the following order:

1. Core services (SecureStorage, NetworkChecker)
2. Firebase services
3. API services with keys from Firebase Remote Config
4. Repositories
5. BLoCs

This sequence ensures all dependencies are properly initialized before the app UI renders.

## Best Practices

This project adheres to the following best practices:

- **Widget Composition**: Breaking UI into small, reusable widgets
- **Text Styling**: Using predefined text styles from AppTextStyles
- **State Management**: Following proper BLoC architecture with events and states
- **Error Boundaries**: Implementing proper error handling at all levels
- **Responsive Design**: Adapting UI to different screen sizes
- **Testing**: Unit tests for logic, widget tests for UI components
