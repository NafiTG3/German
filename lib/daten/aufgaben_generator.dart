import 'dart:math';

import 'package:deutsch_pfad/modelle/aufgabe.dart';
import 'package:deutsch_pfad/modelle/tag.dart';
import 'package:deutsch_pfad/modelle/wort.dart';

abstract final class AufgabenGenerator {
  static final _buchstabe = RegExp(r'\p{L}', unicode: true);
  static final _artikel = RegExp(r'^(der|die|das)\s+', caseSensitive: false);

  static String kern(String de) => de.replaceFirst(_artikel, '');

  static List<Aufgabe> erzeuge(Tag tag, List<Wort> pool, {Random? zufall}) {
    final z = zufall ?? Random();
    final woerter = tag.woerter;
    if (woerter.isEmpty) return const [];

    final aufgaben = <Aufgabe>[];
    for (final w in woerter) {
      final a = _wahl(w, z.nextBool(), woerter, pool, z);
      if (a != null) aufgaben.add(a);
    }

    final gemischt = [...woerter]..shuffle(z);
    var luecken = 0;
    for (final w in gemischt) {
      if (luecken >= 4) break;
      final a = _luecke(w, woerter, pool, z);
      if (a != null) {
        aufgaben.add(a);
        luecken++;
      }
    }
    for (final w in gemischt.take(3)) {
      final a = _hoeren(w, woerter, pool, z);
      if (a != null) aufgaben.add(a);
    }

    aufgaben.shuffle(z);
    return aufgaben;
  }

  static Aufgabe? _wahl(Wort w, bool deZuBn, List<Wort> tagWoerter,
      List<Wort> pool, Random z) {
    final richtig = deZuBn ? w.bn : w.de;
    final ablenker = _ablenker(
      richtig,
      tagWoerter.map((x) => deZuBn ? x.bn : x.de),
      pool.map((x) => deZuBn ? x.bn : x.de),
      z,
    );
    if (ablenker.isEmpty || richtig.isEmpty) return null;
    final optionen = [...ablenker, richtig]..shuffle(z);
    return Aufgabe(
      art: deZuBn ? AufgabenArt.deZuBn : AufgabenArt.bnZuDe,
      frage: deZuBn ? w.de : w.bn,
      optionen: optionen,
      richtig: optionen.indexOf(richtig),
      wort: w,
      vorlesen: w.de,
    );
  }

  static Aufgabe? _luecke(
      Wort w, List<Wort> tagWoerter, List<Wort> pool, Random z) {
    final gesucht = kern(w.de);
    final index = _finde(w.beispiel, gesucht);
    if (index < 0) return null;
    final ablenker = _ablenker(
      gesucht,
      tagWoerter.map((x) => kern(x.de)),
      pool.map((x) => kern(x.de)),
      z,
    );
    if (ablenker.isEmpty) return null;
    final optionen = [...ablenker, gesucht]..shuffle(z);
    return Aufgabe(
      art: AufgabenArt.luecke,
      frage: w.beispiel.replaceRange(index, index + gesucht.length, '_____'),
      hinweis: w.beispielBn,
      optionen: optionen,
      richtig: optionen.indexOf(gesucht),
      wort: w,
      vorlesen: w.beispiel,
    );
  }

  static Aufgabe? _hoeren(
      Wort w, List<Wort> tagWoerter, List<Wort> pool, Random z) {
    final ablenker = _ablenker(
      w.de,
      tagWoerter.map((x) => x.de),
      pool.map((x) => x.de),
      z,
    );
    if (ablenker.isEmpty || w.de.isEmpty) return null;
    final optionen = [...ablenker, w.de]..shuffle(z);
    return Aufgabe(
      art: AufgabenArt.hoeren,
      frage: '',
      optionen: optionen,
      richtig: optionen.indexOf(w.de),
      wort: w,
      vorlesen: w.de,
    );
  }

  // Erst Ablenker aus dem Tag, dann aus dem gesamten Wortschatz
  static List<String> _ablenker(
    String richtig,
    Iterable<String> nah,
    Iterable<String> fern,
    Random z,
  ) {
    final nahListe = nah.toSet().toList()..shuffle(z);
    final fernListe = fern.toSet().toList()..shuffle(z);
    final ergebnis = <String>[];
    for (final k in [...nahListe, ...fernListe]) {
      if (ergebnis.length == 3) break;
      if (k.isNotEmpty && k != richtig && !ergebnis.contains(k)) {
        ergebnis.add(k);
      }
    }
    return ergebnis;
  }

  // Findet das Wort als ganzes Wort, ohne Beachtung der Groß- und Kleinschreibung
  static int _finde(String satz, String gesucht) {
    if (gesucht.isEmpty) return -1;
    final s = satz.toLowerCase();
    final k = gesucht.toLowerCase();
    if (s.length != satz.length) return -1;
    var start = 0;
    while (true) {
      final i = s.indexOf(k, start);
      if (i < 0) return -1;
      final ende = i + k.length;
      final davor = i == 0 || !_buchstabe.hasMatch(s[i - 1]);
      final danach = ende >= s.length || !_buchstabe.hasMatch(s[ende]);
      if (davor && danach) return i;
      start = i + 1;
    }
  }
}
