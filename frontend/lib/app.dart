import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'config/routes.dart';
import 'providers/theme_provider.dart';

class FerreteriaApp extends ConsumerWidget {
  const FerreteriaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    final platform = MediaQuery.platformBrightnessOf(context);

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );

    final theme = FlexThemeData.light(
      scheme: FlexScheme.deepPurple,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 10,
      appBarStyle: FlexAppBarStyle.scaffoldBackground,
      appBarElevation: 0,
      appBarBackground: Colors.white,
      scaffoldBackground: const Color(0xFFF8F6FC),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 15,
        blendOnColors: false,
        useM2StyleDividerInM3: false,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        defaultRadius: 16,
        elevatedButtonRadius: 16,
        outlinedButtonRadius: 16,
        textButtonRadius: 12,
        filledButtonRadius: 16,
        buttonPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        chipRadius: 12,
        snackBarRadius: 12,
        cardRadius: 20,
        dialogRadius: 24,
        popupMenuRadius: 12,
        menuRadius: 12,
        inputDecoratorRadius: 12,
        inputDecoratorContentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        inputDecoratorBorderType: FlexInputBorderType.outline,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );

    final darkTheme = FlexThemeData.dark(
      scheme: FlexScheme.deepPurple,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 12,
      appBarStyle: FlexAppBarStyle.scaffoldBackground,
      appBarElevation: 0,
      appBarBackground: const Color(0xFF13121A),
      scaffoldBackground: const Color(0xFF13121A),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useM2StyleDividerInM3: false,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        defaultRadius: 16,
        elevatedButtonRadius: 16,
        outlinedButtonRadius: 16,
        textButtonRadius: 12,
        filledButtonRadius: 16,
        buttonPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        chipRadius: 12,
        snackBarRadius: 12,
        cardRadius: 20,
        dialogRadius: 24,
        popupMenuRadius: 12,
        menuRadius: 12,
        inputDecoratorRadius: 12,
        inputDecoratorContentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        inputDecoratorBorderType: FlexInputBorderType.outline,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );

    return MaterialApp.router(
      title: 'Ferretería POS',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: resolveThemeMode(themeMode, platform),
      routerConfig: goRouter,
    );
  }
}