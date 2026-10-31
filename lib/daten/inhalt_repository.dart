import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:deutsch_pfad/kern/konstanten.dart';
import 'package:deutsch_pfad/modelle/tag.dart';
import 'package:deutsch_pfad/modelle/wort.dart';

class Inhalt {
  Inhalt(this.tage)
      : woerter = {
          for (final t in tage)
            for (final w in t.woerter) w.de: w,
        };

  final List<Tag> tage;
  final Map<String, Wort> woerter;

  List<Wort> get alleWoerter => woerter.values.toList();

  Tag? tagMitNummer(int nummer) {
    for (final t in tage) {
      if (t.nummer == nummer) return t;
    }
    return null;
  }
}

abstract final class InhaltRepository {
  static Future<Inhalt> laden() async {
    final roh = await rootBundle.loadString(Konstanten.inhaltPfad);
    final liste = (jsonDecode(roh) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Tag.ausJson)
        .where((t) => t.nummer > 0)
        .toList()
      ..sort((a, b) => a.nummer.compareTo(b.nummer));
    return Inhalt(liste);
  }
}
