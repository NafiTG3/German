import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:deutsch_pfad/kern/farben.dart';
import 'package:deutsch_pfad/kern/schriften.dart';

ThemeData baueThema() {
  final schema = ColorScheme.fromSeed(
    seedColor: Farben.signal,
    brightness: Brightness.light,
  ).copyWith(
    primary: Farben.signal,
    onPrimary: Colors.white,
    surface: Farben.papier,
    onSurface: Farben.tinte,
  );
  final basis = ThemeData(
    useMaterial3: true,
    colorScheme: schema,
    scaffoldBackgroundColor: Farben.papier,
  );
  return basis.copyWith(
    textTheme: GoogleFonts.dmSansTextTheme(basis.textTheme).apply(
      bodyColor: Farben.tinte,
      displayColor: Farben.tinte,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Farben.papier,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Farben.tinte,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Farben.papier,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Farben.signalHell,
      labelTextStyle: WidgetStateProperty.all(
        Schriften.text(12, gewicht: FontWeight.w600),
      ),
    ),
  );
}
