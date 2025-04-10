import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Temperature styles
  static TextStyle get temperatureStyle => GoogleFonts.roboto(
    fontSize: 96,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // City name style
  static TextStyle get cityNameStyle => GoogleFonts.roboto(
    fontSize: 36,
    fontWeight: FontWeight.w100,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Day forecast style
  static TextStyle get dayForecastStyle => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Temperature forecast style
  static TextStyle get tempForecastStyle => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Header styles
  static TextStyle get headerStyle => GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Body text styles
  static TextStyle get bodyStyle => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
}
