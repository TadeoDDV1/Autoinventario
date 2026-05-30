import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'config/routes.dart';

class FerreteriaApp extends ConsumerWidget {
  const FerreteriaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    final theme = FlexThemeData.light(
      scheme: FlexScheme.blue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );

    final darkTheme = FlexThemeData.dark(
      scheme: FlexScheme.blue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );

    return MaterialApp.router(
      title: 'Ferretería POS',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      routerConfig: goRouter,
    );
  }
}
