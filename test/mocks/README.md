# Test Mocks Standardization Guide

## Mocking Strategy

This project uses a standardized mocking approach based on Mockito's code generation system via the `@GenerateNiceMocks` annotation.

## How to Use

### Key Files

- `mock_generators.dart` - The central file containing all mock annotations for the project
- `mock_generators.mocks.dart` - The generated mocks file (don't modify directly)
- `test_helpers.dart` - Helper functions for setting up mocks for tests

### Adding a New Mock

1. Add the interface to `mock_generators.dart` within the appropriate section:

```dart
@GenerateNiceMocks([
  // Add your new interface here
  MockSpec<YourInterface>(),
])
```

2. Run the build_runner command to generate the mocks:

```bash
dart run build_runner build --delete-conflicting-outputs
```

3. The mock will be available as `MockYourInterface` in `mock_generators.mocks.dart`

### Using Mocks in Tests

```dart
import 'package:test/test.dart';
import '../mocks/test_helpers.dart';
import '../mocks/mock_generators.mocks.dart';

void main() {
  late MockYourInterface mockInterface;
  
  setUp(() {
    setupTestDependencies(); // Sets up all registered mocks
    mockInterface = MockYourInterface();
  });
  
  tearDown(() {
    tearDownTestDependencies(); // Clears registered mocks
  });
  
  test('your test', () {
    // Use your mock
  });
}
```

## Custom Mock Behavior

If you need to add custom behavior to generated mocks, use an extension method:

```dart
extension MockYourInterfaceExtension on MockYourInterface {
  void mockCustomMethod(ReturnType value) {
    when(someMethod()).thenReturn(value);
  }
}
```

## Deprecated Approaches

⚠️ **Do not use** the following approaches that were previously found in the codebase:

1. Manual mock implementations (e.g., `mock_location_repository.dart`)
2. Multiple mock generator files (repositories/location_repository_mock.dart, etc.)

The project is standardizing on a single centralized mock generator and using only generated mocks.

## Standardized Mocks

The following mocks have been standardized and are available in `mock_generators.mocks.dart`:

- `MockILocationRepository` - For location data operations
- `MockIWeatherRepository` - For weather forecast operations
- `MockLoadingManager` - For UI loading state management
- `MockNetworkChecker` - For network connectivity checks
- `MockApiClient` - For API interaction
- `MockLocationBloc` - For location state management
- `MockWeatherBloc` - For weather state management

**Note:** The old mock implementations in `repositories/mock_weather_repository.dart` and 
`repositories/weather_repository_mock.dart` have been removed in favor of the standardized approach. 