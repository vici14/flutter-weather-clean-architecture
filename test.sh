#!/bin/bash

# Clean previous coverage data
rm -rf coverage

# Ensure Flutter test binding is initialized with custom setup
flutter test test/test_helpers/init_tests.dart

# Run all tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html

# Check coverage threshold
COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | cut -d ' ' -f 4 | cut -d '%' -f 1)
if (( $(echo "$COVERAGE < 80" | bc -l) )); then
    echo "Coverage is below 80% ($COVERAGE%)"
    exit 1
else
    echo "Coverage is at $COVERAGE% - PASSED"
fi

# Open coverage report
open coverage/html/index.html 