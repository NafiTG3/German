import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_pfad/daten/aufgaben_generator.dart';
import 'package:deutsch_pfad/modelle/tag.dart';
import 'package:deutsch_pfad/modelle/wort.dart';

void main() {
  const tag = Tag(
    nummer: 1,
    thema: 'Test',
    themaBn: '',
    grammatikTitel: '',
    grammatikText: '',
    woerter: [
      Wort(de: 'die Mutter', bn: 'মা', beispiel: 'Meine Mutter ist Lehrerin.', beispielBn: 'আমার মা শিক্ষিকা।'),
      Wort(de: 'der Vater', bn: 'বাবা', beispiel: 'Mein Vater arbeitet viel.', beispielBn: 'আমার বাবা অনেক কাজ করেন।'),
      Wort(de: 'der Bruder', bn: 'ভাই', beispiel: 'Ich habe einen Bruder.', beispielBn: 'আমার একজন ভাই আছে।'),
      Wort(de: 'die Schwester', bn: 'বোন', beispiel: 'Meine Schwester wohnt hier.', beispielBn: 'আমার বোন এখানে থাকে।'),
    ],
    dialog: [],
  );

  test('Optionen sind eindeutig und der Index der richtigen Antwort stimmt', () {
    final aufgaben =
        AufgabenGenerator.erzeuge(tag, tag.woerter, zufall: Random(1));
    expect(aufgaben, isNotEmpty);
    for (final a in aufgaben) {
      expect(a.optionen.toSet().length, a.optionen.length);
      expect(a.richtig, inInclusiveRange(0, a.optionen.length - 1));
    }
  });

  test('Lückenaufgabe ersetzt das Wort ohne Artikel', () {
    final aufgaben =
        AufgabenGenerator.erzeuge(tag, tag.woerter, zufall: Random(2));
    final luecken = aufgaben.where((a) => a.frage.contains('_____'));
    expect(luecken, isNotEmpty);
  });

  test('kern entfernt den Artikel', () {
    expect(AufgabenGenerator.kern('der Tisch'), 'Tisch');
    expect(AufgabenGenerator.kern('Hallo'), 'Hallo');
  });
}
