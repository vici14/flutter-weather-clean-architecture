import 'package:flutter_test/flutter_test.dart';
import 'dummy_values.dart';

/// This file provides global initialization for all tests
void main() {
  // Initialize Flutter test binding
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register all dummy values for Either types
  registerDummyValues();

  // This simple test ensures the initialization runs
  test('Initialization complete', () {
    expect(true, isTrue);
  });
}
