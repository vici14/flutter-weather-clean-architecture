#!/bin/bash

# Clean previous coverage data
rm -rf coverage
rm -rf test/.test_coverage.dart

# Run unit tests with coverage
flutter test --coverage test/unit

# Run widget tests with coverage
flutter test --coverage test/widget

# Combine coverage data
lcov --add-tracefile coverage/lcov.info -o coverage/lcov_unit.info
lcov --add-tracefile coverage/lcov.info -o coverage/lcov_widget.info
lcov -a coverage/lcov_unit.info -a coverage/lcov_widget.info -o coverage/lcov.info

# Run integration tests
flutter test integration_test

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html

# Check coverage threshold
COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | cut -d ' ' -f 4 | cut -d '%' -f 1)
if (( $(echo "$COVERAGE < 80" | bc -l) )); then
    echo "Coverage is below 80% ($COVERAGE%)"
    exit 1
else
    echo "Coverage is at $COVERAGE%"
fi

# Open coverage report
open coverage/html/index.html 