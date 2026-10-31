import 'package:deutsch_pfad/modelle/wort.dart';

enum AufgabenArt { deZuBn, bnZuDe, luecke, hoeren }

class Aufgabe {
  const Aufgabe({
    required this.art,
    required this.frage,
    required this.optionen,
    required this.richtig,
    required this.wort,
    this.hinweis,
    this.vorlesen,
  });

  final AufgabenArt art;
  final String frage;
  final List<String> optionen;
  final int richtig;
  final Wort wort;
  final String? hinweis;
  final String? vorlesen;

  String get richtigeAntwort => optionen[richtig];
}
