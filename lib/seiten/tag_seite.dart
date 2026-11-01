import 'package:flutter/material.dart';

import 'package:deutsch_pfad/dienste/sprach_dienst.dart';
import 'package:deutsch_pfad/kern/abstand.dart';
import 'package:deutsch_pfad/kern/farben.dart';
import 'package:deutsch_pfad/kern/lehrplan.dart';
import 'package:deutsch_pfad/kern/schriften.dart';
import 'package:deutsch_pfad/modelle/tag.dart';
import 'package:deutsch_pfad/modelle/wort.dart';
import 'package:deutsch_pfad/seiten/uebung_seite.dart';
import 'package:deutsch_pfad/widgets/etikett.dart';
import 'package:deutsch_pfad/widgets/natur_hintergrund.dart';
import 'package:deutsch_pfad/widgets/ton_knopf.dart';
import 'package:deutsch_pfad/zustand/app_daten.dart';

class TagSeite extends StatelessWidget {
  const TagSeite({super.key, required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    final fortschritt = AppDaten.von(context).fortschritt;
    final woche = Lehrplan.wocheVonTag(tag.nummer);
    final erstePerson = tag.dialog.isEmpty ? '' : tag.dialog.first.sprecher;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tag ${tag.nummer}',
            style: Schriften.text(16, gewicht: FontWeight.w600)),
      ),
      body: NaturSeite(child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Etikett('Woche $woche'),
          const SizedBox(height: Abstand.a8),
          Text(tag.thema, style: Schriften.anzeige(44)),
          Text(tag.themaBn, style: Schriften.bangla(20)),
          const SizedBox(height: Abstand.a32),
          _Abschnitt(titel: 'Wörter', bn: 'শব্দ · ${tag.woerter.length}টি'),
          ...tag.woerter.map((w) => _WortKarte(wort: w)),
          if (tag.grammatikText.isNotEmpty) ...[
            const SizedBox(height: Abstand.a24),
            _Abschnitt(titel: 'Grammatik', bn: 'ব্যাকরণ'),
            _GrammatikBlock(titel: tag.grammatikTitel, text: tag.grammatikText),
          ],
          if (tag.dialog.isNotEmpty) ...[
            const SizedBox(height: Abstand.a32),
            _Abschnitt(titel: 'Dialog', bn: 'কথোপকথন · ট্যাপ করে শোনো'),
            ...tag.dialog.map(
              (z) => _Blase(zeile: z, links: z.sprecher == erstePerson),
            ),
          ],
        ],
      )),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: ListenableBuilder(
            listenable: fortschritt,
            builder: (context, _) {
              final best = fortschritt.bestesErgebnis(tag.nummer);
              return FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Farben.signal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: Schriften.text(16, gewicht: FontWeight.w700),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => UebungSeite(tag: tag),
                  ),
                ),
                child: Text(best == null
                    ? 'Übung starten'
                    : 'Übung starten · bisher $best %'),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Abschnitt extends StatelessWidget {
  const _Abschnitt({required this.titel, required this.bn});

  final String titel;
  final String bn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Abstand.a12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(titel, style: Schriften.anzeige(24)),
          const SizedBox(width: Abstand.a12),
          Flexible(child: Text(bn, style: Schriften.bangla(14))),
        ],
      ),
    );
  }
}

class _WortKarte extends StatelessWidget {
  const _WortKarte({required this.wort});

  final Wort wort;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Abstand.a12),
      decoration: BoxDecoration(
        color: Farben.karte,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Farben.linie),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(wort.de, style: Schriften.anzeige(24)),
                      Text(wort.bn, style: Schriften.bangla(16)),
                    ],
                  ),
                ),
                TonKnopf(text: wort.de),
              ],
            ),
            if (wort.beispiel.isNotEmpty)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => SprachDienst.instanz.sprich(wort.beispiel),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.play_arrow_rounded,
                            size: 20, color: Farben.signal),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(wort.beispiel, style: Schriften.text(15)),
                            Text(wort.beispielBn, style: Schriften.bangla(13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(height: Abstand.a8),
          ],
        ),
      ),
    );
  }
}

class _GrammatikBlock extends StatelessWidget {
  const _GrammatikBlock({required this.titel, required this.text});

  final String titel;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Farben.papierDunkel),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: Farben.signal),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titel, style: Schriften.anzeige(20)),
                      const SizedBox(height: Abstand.a8),
                      Text(text,
                          style: Schriften.bangla(16, farbe: Farben.tinte)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Blase extends StatelessWidget {
  const _Blase({required this.zeile, required this.links});

  final Dialogzeile zeile;
  final bool links;

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(18);
    return Padding(
      padding: const EdgeInsets.only(bottom: Abstand.a12),
      child: Align(
        alignment: links ? Alignment.centerLeft : Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Material(
            color: links ? Farben.karte : Farben.papierDunkel,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Farben.linie),
              borderRadius: BorderRadius.only(
                topLeft: radius,
                topRight: radius,
                bottomLeft: links ? const Radius.circular(4) : radius,
                bottomRight: links ? radius : const Radius.circular(4),
              ),
            ),
            child: InkWell(
              onTap: () => SprachDienst.instanz.sprich(zeile.de),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Etikett(zeile.sprecher),
                    const SizedBox(height: 4),
                    Text(zeile.de,
                        style: Schriften.text(17, gewicht: FontWeight.w500)),
                    Text(zeile.bn, style: Schriften.bangla(14)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
