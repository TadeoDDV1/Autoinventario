import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF651FFF);
  static const Color primaryLight = Color(0xFF7C4DFF);
  static const Color primaryDark = Color(0xFF4A00E0);
  static const Color primaryContainer = Color(0xFFE8E3F5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1A1B41);

  static const Color secondary = Color(0xFFE91E63);
  static const Color secondaryLight = Color(0xFFFF4081);
  static const Color secondaryContainer = Color(0xFFFCE4EC);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF4A002E);

  static const Color tertiary = Color(0xFF00BFA5);
  static const Color tertiaryContainer = Color(0xFFD4FCF8);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF003D39);

  static const Color success = Color(0xFF4CAF50);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFFE65100);

  static const Color error = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFFDEDEC);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFFB71C1C);

  static const Color surface = Color(0xFFF8F6FC);
  static const Color surfaceContainerLow = Color(0xFFF0ECF9);
  static const Color surfaceContainer = Color(0xFFE8E3F5);
  static const Color surfaceContainerHigh = Color(0xFFDED7EB);
  static const Color surfaceContainerHighest = Color(0xFFD4CCE0);
  static const Color onSurface = Color(0xFF1A1B41);
  static const Color onSurfaceVariant = Color(0xFF6B6B8D);

  static const Color outline = Color(0xFFE0DCF0);
  static const Color outlineVariant = Color(0xFFE8E3F5);
  static const Color shadow = Color(0x1A1A1B41);
  static const Color shadowMedium = Color(0x331A1B41);
  static const Color shadowLarge = Color(0x4D1A1B41);

  static const Color inverseSurface = Color(0xFF1A1B41);
  static const Color inversePrimary = Color(0xFFB8A8FF);
  static const Color inverseOnSurface = Color(0xFFF8F6FC);

  static const Color surfaceDim = Color(0xFFD8D5E0);
  static const Color surfaceBright = Color(0xFFFFFBFF);
  static const Color surfaceTint = Color(0xFF651FFF);
  static const Color scrim = Color(0xFF000000);

  static const Color background = Color(0xFFF8F6FC);
  static const Color onBackground = Color(0xFF1A1B41);

  static const Color darkPrimary = Color(0xFFB8A8FF);
  static const Color darkPrimaryContainer = Color(0xFF4A00E0);
  static const Color darkOnPrimaryContainer = Color(0xFFF8F6FC);
  static const Color darkSecondary = Color(0xFFFF80AB);
  static const Color darkSecondaryContainer = Color(0xFF6B1A3D);
  static const Color darkTertiary = Color(0xFF7EF9E5);
  static const Color darkTertiaryContainer = Color(0xFF00524D);
  static const Color darkSurface = Color(0xFF13121A);
  static const Color darkSurfaceContainerLow = Color(0xFF1D1C24);
  static const Color darkSurfaceContainer = Color(0xFF25242D);
  static const Color darkSurfaceContainerHigh = Color(0xFF31303A);
  static const Color darkSurfaceContainerHighest = Color(0xFF3D3B46);
  static const Color darkOnSurface = Color(0xFFF8F6FC);
  static const Color darkOnSurfaceVariant = Color(0xFFC8C5D0);
  static const Color darkOutline = Color(0xFF4A4953);
  static const Color darkOutlineVariant = Color(0xFF3D3B46);
  static const Color darkShadow = Color(0xFF000000);
  static const Color darkBackground = Color(0xFF13121A);
  static const Color darkOnBackground = Color(0xFFF8F6FC);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [darkPrimaryContainer, darkPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [Color(0xFFF8F6FC), Color(0xFFE8E3F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF13121A), Color(0xFF1D1C24)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, surfaceContainerLow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradientDark = LinearGradient(
    colors: [darkSurface, darkSurfaceContainerLow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F6FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF1D1C24), Color(0xFF13121A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        shadow: shadow,
        inverseSurface: inverseSurface,
        onInverseSurface: inverseOnSurface,
        inversePrimary: inversePrimary,
        surfaceTint: surfaceTint,
        scrim: scrim,
      );

  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkOnPrimaryContainer,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        secondary: darkSecondary,
        onSecondary: darkOnPrimaryContainer,
        secondaryContainer: darkSecondaryContainer,
        onSecondaryContainer: darkOnPrimaryContainer,
        tertiary: darkTertiary,
        onTertiary: darkOnPrimaryContainer,
        tertiaryContainer: darkTertiaryContainer,
        onTertiaryContainer: darkOnPrimaryContainer,
        error: Color(0xFFF2B8B5),
        onError: Color(0xFF601410),
        errorContainer: Color(0xFF8C1D18),
        onErrorContainer: Color(0xFFFDEDEC),
        surface: darkSurface,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: darkOutline,
        outlineVariant: darkOutlineVariant,
        shadow: darkShadow,
        inverseSurface: surface,
        onInverseSurface: onSurface,
        inversePrimary: primary,
        surfaceTint: darkPrimary,
        scrim: scrim,
      );
}