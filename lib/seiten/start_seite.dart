import 'package:flutter/material.dart';

import 'package:deutsch_pfad/daten/inhalt_repository.dart';
import 'package:deutsch_pfad/kern/abstand.dart';
import 'package:deutsch_pfad/kern/farben.dart';
import 'package:deutsch_pfad/kern/konstanten.dart';
import 'package:deutsch_pfad/kern/lehrplan.dart';
import 'package:deutsch_pfad/kern/schriften.dart';
import 'package:deutsch_pfad/modelle/tag.dart';
import 'package:deutsch_pfad/seiten/tag_seite.dart';
import 'package:deutsch_pfad/widgets/etikett.dart';
import 'package:deutsch_pfad/widgets/fortschrittsbalken.dart';
import 'package:deutsch_pfad/zustand/app_daten.dart';
import 'package:deutsch_pfad/zustand/fortschritt_modell.dart';

String _gruss(int stunde) =>
    stunde < 11 ? 'Guten Morgen' : (stunde < 18 ? 'Guten Tag' : 'Guten Abend');

String _grussBn(int stunde) =>
    stunde < 11 ? 'শুভ সকাল' : (stunde < 18 ? 'শুভ দিন' : 'শুভ সন্ধ্যা');

void _oeffneTag(BuildContext context, Tag tag) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => TagSeite(tag: tag)),
  );
}

class StartSeite extends StatelessWidget {
  const StartSeite({super.key, required this.zumWiederholen});

  final VoidCallback zumWiederholen;

  @override
  Widget build(BuildContext context) {
    final daten = AppDaten.von(context);
    return ListenableBuilder(
      listenable: daten.fortschritt,
      builder: (context, _) {
        final f = daten.fortschritt;
        final inhalt = daten.inhalt;
        final stunde = DateTime.now().hour;
        final aktuell = _aktuellerTag(inhalt, f);
        final faellig = f.faelligeKarten().length;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      const Etikett('Deutsch Pfad'),
                      const Spacer(),
                      _SerieChip(serie: f.serie),
                    ],
                  ),
                  const SizedBox(height: Abstand.a16),
                  Text.rich(
                    TextSpan(
                      text: _gruss(stunde),
                      style: Schriften.anzeige(44),
                      children: [
                        TextSpan(
                          text: '.',
                          style: Schriften.anzeige(44, farbe: Farben.signal),
                        ),
                      ],
                    ),
                  ),
                  Text(_grussBn(stunde), style: Schriften.bangla(16)),
                  const SizedBox(height: Abstand.a24),
                  if (aktuell != null)
                    _HeldenKarte(tag: aktuell)
                  else
                    const _FertigKarte(),
                  const SizedBox(height: Abstand.a16),
                  _WiederholenKarte(faellig: faellig, onTap: zumWiederholen),
                  const SizedBox(height: Abstand.a24),
                  _WegZuB1(f: f),
                  const SizedBox(height: Abstand.a32),
                  Text('112 Tage, 16 Wochen', style: Schriften.anzeige(24)),
                  Text('প্রতিটি সারি একটি সপ্তাহ', style: Schriften.bangla(14)),
                  const SizedBox(height: Abstand.a16),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Konstanten.tageProWoche,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: Konstanten.gesamtTage,
                  (context, i) {
                    final nummer = i + 1;
                    final tag = inhalt.tagMitNummer(nummer);
                    return _TagKachel(
                      nummer: nummer,
                      erledigt: f.istErledigt(nummer),
                      aktuell: aktuell?.nummer == nummer,
                      onTap: tag == null ? null : () => _oeffneTag(context, tag),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Tag? _aktuellerTag(Inhalt inhalt, FortschrittModell f) {
    for (final t in inhalt.tage) {
      if (!f.istErledigt(t.nummer)) return t;
    }
    return null;
  }
}

class _SerieChip extends StatelessWidget {
  const _SerieChip({required this.serie});

  final int serie;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$serie Tage in Folge',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: serie > 0 ? Farben.signalHell : Farben.papierDunkel,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 18,
              color: serie > 0 ? Farben.signal : Farben.tinteGedaempft,
            ),
            const SizedBox(width: 4),
            Text('$serie', style: Schriften.text(14, gewicht: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _HeldenKarte extends StatelessWidget {
  const _HeldenKarte({required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    final woche = Lehrplan.wocheVonTag(tag.nummer);
    return Material(
      color: Farben.tinte,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _oeffneTag(context, tag),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Etikett('Heute · Woche $woche', farbe: Farben.papierDunkel),
              const SizedBox(height: Abstand.a8),
              Text(
                tag.nummer.toString().padLeft(2, '0'),
                style: Schriften.anzeige(
                  112,
                  farbe: Farben.papier,
                  gewicht: FontWeight.w300,
                  hoehe: 0.95,
                ),
              ),
              const SizedBox(height: Abstand.a8),
              Text(tag.thema,
                  style: Schriften.anzeige(28, farbe: Farben.papier)),
              Text(tag.themaBn,
                  style: Schriften.bangla(16, farbe: Farben.papierDunkel)),
              const SizedBox(height: Abstand.a24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Farben.signal,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Lektion starten',
                        style: Schriften.text(16,
                            farbe: Colors.white, gewicht: FontWeight.w700)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FertigKarte extends StatelessWidget {
  const _FertigKarte();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Farben.papierDunkel,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alle Lektionen geschafft.', style: Schriften.anzeige(28)),
          const SizedBox(height: Abstand.a8),
          Text('নতুন পাঠ শীঘ্রই যুক্ত হবে। ততক্ষণ রিভিশন চালিয়ে যাও।',
              style: Schriften.bangla(16)),
        ],
      ),
    );
  }
}

class _WiederholenKarte extends StatelessWidget {
  const _WiederholenKarte({required this.faellig, required this.onTap});

  final int faellig;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Farben.karte,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Farben.linie),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text('$faellig',
                  style: Schriften.anzeige(40,
                      farbe: faellig > 0 ? Farben.signal : Farben.tinteGedaempft)),
              const SizedBox(width: Abstand.a16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faellig > 0 ? 'Karten zum Wiederholen' : 'Heute nichts fällig',
                      style: Schriften.text(16, gewicht: FontWeight.w600),
                    ),
                    Text(
                      faellig > 0 ? 'রিভিশন বাকি আছে' : 'আজকের রিভিশন শেষ',
                      style: Schriften.bangla(14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _WegZuB1 extends StatelessWidget {
  const _WegZuB1({required this.f});

  final FortschrittModell f;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Etikett('Dein Weg zu B1'),
            const Spacer(),
            Text(
              '${f.erledigteTage} / ${Konstanten.gesamtTage} Tage · ${f.gelernteWoerter} Wörter',
              style: Schriften.text(13, farbe: Farben.tinteGedaempft),
            ),
          ],
        ),
        const SizedBox(height: Abstand.a8),
        Fortschrittsbalken(wert: f.erledigteTage / Konstanten.gesamtTage),
      ],
    );
  }
}

class _TagKachel extends StatelessWidget {
  const _TagKachel({
    required this.nummer,
    required this.erledigt,
    required this.aktuell,
    required this.onTap,
  });

  final int nummer;
  final bool erledigt;
  final bool aktuell;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gesperrt = onTap == null;
    final Color fuellung = erledigt
        ? Farben.tinte
        : (gesperrt ? Colors.transparent : Farben.papierDunkel);
    final Color schrift = erledigt
        ? Farben.papier
        : (gesperrt ? Farben.tinteGedaempft : Farben.tinte);
    return Semantics(
      button: !gesperrt,
      label: 'Tag $nummer${erledigt ? ', erledigt' : ''}',
      child: Material(
        color: fuellung,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: aktuell ? Farben.signal : (gesperrt ? Farben.linie : Colors.transparent),
            width: aktuell ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              '$nummer',
              style: Schriften.text(13, farbe: schrift, gewicht: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
