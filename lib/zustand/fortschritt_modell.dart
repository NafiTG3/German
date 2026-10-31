import 'dart:math' as mathe;

import 'package:flutter/foundation.dart';

import 'package:deutsch_pfad/daten/fortschritt_speicher.dart';
import 'package:deutsch_pfad/kern/konstanten.dart';
import 'package:deutsch_pfad/modelle/tag.dart';

class _Karte {
  _Karte(this.box, this.faellig);

  int box;
  String faellig;
}

class FortschrittModell extends ChangeNotifier {
  FortschrittModell(this._speicher);

  final FortschrittSpeicher _speicher;
  final Map<int, int> _ergebnisse = {};
  final Map<String, _Karte> _karten = {};
  final Set<String> _aktiveTage = {};

  // Leitner-Boxen: Box, Wiederholung nach N Tagen
  static const _intervalle = <int, int>{1: 1, 2: 2, 3: 4, 4: 8, 5: 16};

  static String tagesSchluessel(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _inTagen(int n) {
    final j = DateTime.now();
    return DateTime(j.year, j.month, j.day + n);
  }

  Future<void> laden() async {
    final daten = await _speicher.lesen();

    final ergebnisse = daten['ergebnisse'];
    if (ergebnisse is Map) {
      for (final e in ergebnisse.entries) {
        final nr = int.tryParse('${e.key}');
        final wert = e.value;
        if (nr != null && wert is num) _ergebnisse[nr] = wert.toInt();
      }
    }

    final karten = daten['karten'];
    if (karten is Map) {
      for (final e in karten.entries) {
        final wert = e.value;
        if (wert is List &&
            wert.length == 2 &&
            wert[0] is num &&
            wert[1] is String) {
          final box = mathe.min(5, mathe.max(1, (wert[0] as num).toInt()));
          _karten['${e.key}'] = _Karte(box, wert[1] as String);
        }
      }
    }

    final aktiv = daten['aktiv'];
    if (aktiv is List) _aktiveTage.addAll(aktiv.whereType<String>());
  }

  int? bestesErgebnis(int nummer) => _ergebnisse[nummer];

  bool istErledigt(int nummer) =>
      (_ergebnisse[nummer] ?? 0) >= Konstanten.bestehensGrenze;

  int get erledigteTage => _ergebnisse.values
      .where((p) => p >= Konstanten.bestehensGrenze)
      .length;

  int get gelernteWoerter => _karten.length;

  int get serie {
    var tag = DateTime.now();
    if (!_aktiveTage.contains(tagesSchluessel(tag))) {
      tag = DateTime(tag.year, tag.month, tag.day - 1);
    }
    var zaehler = 0;
    while (_aktiveTage.contains(tagesSchluessel(tag))) {
      zaehler++;
      tag = DateTime(tag.year, tag.month, tag.day - 1);
    }
    return zaehler;
  }

  List<String> faelligeKarten() {
    final heute = tagesSchluessel(DateTime.now());
    final faellig = _karten.entries
        .where((e) => e.value.faellig.compareTo(heute) <= 0)
        .toList()
      ..sort((a, b) => a.value.faellig.compareTo(b.value.faellig));
    return faellig.map((e) => e.key).toList();
  }

  Future<void> tagAbschliessen(Tag tag, int prozent) async {
    final alt = _ergebnisse[tag.nummer] ?? 0;
    if (prozent > alt) _ergebnisse[tag.nummer] = prozent;
    final heute = tagesSchluessel(DateTime.now());
    if (prozent >= Konstanten.bestehensGrenze) {
      for (final w in tag.woerter) {
        _karten.putIfAbsent(w.de, () => _Karte(1, heute));
      }
    }
    _aktiveTage.add(heute);
    notifyListeners();
    await _sichern();
  }

  Future<void> kartenAntwort(String schluessel, bool gewusst) async {
    final karte = _karten[schluessel];
    if (karte == null) return;
    karte.box = gewusst ? mathe.min(5, karte.box + 1) : 1;
    karte.faellig = tagesSchluessel(_inTagen(_intervalle[karte.box] ?? 1));
    _aktiveTage.add(tagesSchluessel(DateTime.now()));
    notifyListeners();
    await _sichern();
  }

  Future<void> _sichern() => _speicher.schreiben({
        'ergebnisse': {for (final e in _ergebnisse.entries) '${e.key}': e.value},
        'karten': {
          for (final e in _karten.entries) e.key: [e.value.box, e.value.faellig],
        },
        'aktiv': (_aktiveTage.toList()..sort()),
      });
}
