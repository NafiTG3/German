import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:deutsch_pfad/kern/farben.dart';

abstract final class Schriften {
  // Serif für große Deutsch-Wörter und Überschriften
  static TextStyle anzeige(
    double groesse, {
    Color farbe = Farben.tinte,
    FontWeight gewicht = FontWeight.w600,
    double hoehe = 1.1,
    FontStyle stil = FontStyle.normal,
  }) =>
      GoogleFonts.fraunces(
        fontSize: groesse,
        color: farbe,
        fontWeight: gewicht,
        height: hoehe,
        fontStyle: stil,
        letterSpacing: groesse > 30 ? -groesse * 0.02 : 0,
      );

  static TextStyle text(
    double groesse, {
    Color farbe = Farben.tinte,
    FontWeight gewicht = FontWeight.w400,
    double hoehe = 1.4,
    double abstand = 0,
  }) =>
      GoogleFonts.dmSans(
        fontSize: groesse,
        color: farbe,
        fontWeight: gewicht,
        height: hoehe,
        letterSpacing: abstand,
      );

  static TextStyle bangla(
    double groesse, {
    Color farbe = Farben.tinteGedaempft,
    FontWeight gewicht = FontWeight.w400,
  }) =>
      GoogleFonts.hindSiliguri(
        fontSize: groesse,
        color: farbe,
        fontWeight: gewicht,
        height: 1.5,
      );
}
