import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens de Viví el Sur.
/// Mismos nombres y valores que las variables del archivo de Figma
/// (Foundations) y que las custom properties de `css/app.css`.
abstract final class AppColors {
  static const primaryBlue = Color(0xFF4A80E6);
  static const primaryBlueDark = Color(0xFF325FBF);
  static const textPrimary = Color(0xFF212125);
  static const textSecondary = Color(0xFF6B6B70);
  static const textTertiary = Color(0xFF9E9EA3);
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const surfaceBackground = Color(0xFFFBFAF9);
  static const surfaceMuted = Color(0xFFF6F6F5);
  static const borderDefault = Color(0xFFE5E5E8);
  static const accentAmber = Color(0xFFE1A436);
  static const accentGreen = Color(0xFF429667);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

abstract final class AppRadius {
  static const sm = 12.0;
  static const md = 14.0;
  static const lg = 16.0;
  static const xl = 18.0;
  static const xxl = 20.0;
  static const full = 999.0;
}

abstract final class AppShadows {
  static const small = [BoxShadow(color: Color(0x1F000000), offset: Offset(0, 1), blurRadius: 4)];
  static const medium = [BoxShadow(color: Color(0x2E000000), offset: Offset(0, 6), blurRadius: 20)];
  static const large = [BoxShadow(color: Color(0x29000000), offset: Offset(0, 8), blurRadius: 24)];
}

/// Escala tipográfica (Albert Sans).
abstract final class AppText {
  static TextStyle _base(double size, FontWeight weight, double height, [Color color = AppColors.textPrimary]) =>
      GoogleFonts.albertSans(fontSize: size, fontWeight: weight, height: height, color: color);

  static final display = _base(24, FontWeight.w700, 1.18);
  static final h1 = _base(17, FontWeight.w700, 1.24);
  static final h2 = _base(15, FontWeight.w700, 1.24);
  static final title = _base(14, FontWeight.w700, 1.24);
  static final bodyMedium = _base(13.5, FontWeight.w500, 1.4);
  static final body = _base(13, FontWeight.w400, 1.45);
  static final label = _base(12.5, FontWeight.w600, 1.2);
  static final caption = _base(11.5, FontWeight.w400, 1.4, AppColors.textSecondary);
  static final overline = _base(10.5, FontWeight.w400, 1.3, AppColors.textTertiary);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.surfaceBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      primary: AppColors.primaryBlue,
      surface: AppColors.surfaceWhite,
    ),
    textTheme: GoogleFonts.albertSansTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceWhite,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppText.h2,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.surfaceWhite,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        textStyle: AppText.label,
      ),
    ),
  );
}
