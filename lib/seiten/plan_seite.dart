import 'package:flutter/material.dart';

import 'package:deutsch_pfad/kern/abstand.dart';
import 'package:deutsch_pfad/kern/farben.dart';
import 'package:deutsch_pfad/kern/konstanten.dart';
import 'package:deutsch_pfad/kern/lehrplan.dart';
import 'package:deutsch_pfad/kern/schriften.dart';
import 'package:deutsch_pfad/widgets/etikett.dart';
import 'package:deutsch_pfad/widgets/fortschrittsbalken.dart';
import 'package:deutsch_pfad/zustand/app_daten.dart';

class PlanSeite extends StatelessWidget {
  const PlanSeite({super.key});

  @override
  Widget build(BuildContext context) {
    final daten = AppDaten.von(context);
    return ListenableBuilder(
      listenable: daten.fortschritt,
      builder: (context, _) {
        final f = daten.fortschritt;
        final inhalt = daten.inhalt;
        final kinder = <Widget>[
          const Etikett('Plan'),
          const SizedBox(height: Abstand.a8),
          Text('16 Wochen bis B1', style: Schriften.anzeige(44)),
          Text('১৬ সপ্তাহে B1 পরীক্ষার প্রস্তুতি। তারপর B2।',
              style: Schriften.bangla(16)),
          const SizedBox(height: Abstand.a24),
        ];

        String? letztePhase;
        for (final w in Lehrplan.wochen) {
          if (w.phase != letztePhase) {
            letztePhase = w.phase;
            kinder.add(Padding(
              padding: const EdgeInsets.only(top: Abstand.a16, bottom: Abstand.a12),
              child: Text(Lehrplan.phasen[w.phase] ?? w.phase,
                  style: Schriften.anzeige(24, farbe: Farben.signal)),
            ));
          }
          var erledigt = 0;
          var vorhanden = false;
          for (var t = w.ersterTag; t <= w.letzterTag; t++) {
            if (f.istErledigt(t)) erledigt++;
            if (inhalt.tagMitNummer(t) != null) vorhanden = true;
          }
          kinder.add(_WochenKarte(
            woche: w,
            erledigt: erledigt,
            vorhanden: vorhanden,
          ));
        }

        kinder.add(const SizedBox(height: Abstand.a16));
        kinder.add(Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Farben.tanne,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Etikett('Danach', farbe: Farben.papierDunkel),
              const SizedBox(height: Abstand.a8),
              Text('B2', style: Schriften.anzeige(64, farbe: Farben.papier, gewicht: FontWeight.w300)),
              Text(
                'B1 পাশ করার পর B2 এর আলাদা পরিকল্পনা যুক্ত হবে।',
                style: Schriften.bangla(16, farbe: Farben.papierDunkel),
              ),
            ],
          ),
        ));
        kinder.add(const SizedBox(height: Abstand.a32));

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          children: kinder,
        );
      },
    );
  }
}

class _WochenKarte extends StatelessWidget {
  const _WochenKarte({
    required this.woche,
    required this.erledigt,
    required this.vorhanden,
  });

  final Woche woche;
  final int erledigt;
  final bool vorhanden;

  @override
  Widget build(BuildContext context) {
    final aktiv = vorhanden;
    return Opacity(
      opacity: aktiv ? 1 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: Abstand.a12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Farben.karte,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Farben.linie),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Text(
                woche.nummer.toString().padLeft(2, '0'),
                style: Schriften.anzeige(
                  32,
                  farbe: aktiv ? Farben.tinte : Farben.tinteGedaempft,
                  gewicht: FontWeight.w300,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(woche.thema,
                      style: Schriften.text(16, gewicht: FontWeight.w700)),
                  Text(woche.fokus,
                      style: Schriften.text(13, farbe: Farben.tinteGedaempft)),
                  const SizedBox(height: Abstand.a12),
                  Fortschrittsbalken(
                    wert: erledigt / Konstanten.tageProWoche,
                    hoehe: 6,
                  ),
                  const SizedBox(height: Abstand.a4),
                  Text(
                    aktiv
                        ? '$erledigt / ${Konstanten.tageProWoche} Tage'
                        : 'Inhalt folgt',
                    style: Schriften.text(12, farbe: Farben.tinteGedaempft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
