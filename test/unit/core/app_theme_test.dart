import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/core/theme/app_theme.dart';
import 'package:weather_app_assignment/core/theme/app_colors.dart';

void main() {
  group('AppTheme', () {
    test('lightTheme has correct color scheme', () {
      final theme = AppTheme.lightTheme;

      // Verify it's a ThemeData instance
      expect(theme, isA<ThemeData>());

      // Verify primary color
      expect(theme.colorScheme.primary, AppColors.primary);

      // Verify background color
      expect(theme.scaffoldBackgroundColor, AppColors.background);

      // Verify the theme brightness
      expect(theme.brightness, Brightness.light);

      // Verify the app bar theme
      expect(theme.appBarTheme, isNotNull);
      expect(theme.appBarTheme.backgroundColor, AppColors.background);
    });

    test('darkTheme exists', () {
      final theme = AppTheme.darkTheme;

      // Verify it's a ThemeData instance
      expect(theme, isA<ThemeData>());
    });
  });
}
