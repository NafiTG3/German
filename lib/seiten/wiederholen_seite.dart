import 'package:flutter/material.dart';

import 'package:deutsch_pfad/dienste/sprach_dienst.dart';
import 'package:deutsch_pfad/kern/abstand.dart';
import 'package:deutsch_pfad/kern/farben.dart';
import 'package:deutsch_pfad/kern/schriften.dart';
import 'package:deutsch_pfad/modelle/wort.dart';
import 'package:deutsch_pfad/widgets/etikett.dart';
import 'package:deutsch_pfad/widgets/ton_knopf.dart';
import 'package:deutsch_pfad/zustand/app_daten.dart';

class WiederholenSeite extends StatefulWidget {
  const WiederholenSeite({super.key});

  @override
  State<WiederholenSeite> createState() => _WiederholenSeiteZustand();
}

class _WiederholenSeiteZustand extends State<WiederholenSeite> {
  List<String>? _sitzung;
  int _pos = 0;
  int _gewusst = 0;
  bool _umgedreht = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Schnappschuss, damit sich die Liste während der Sitzung nicht verschiebt
    _sitzung ??= AppDaten.von(context).fortschritt.faelligeKarten();
  }

  Future<void> _antwort(bool gewusst) async {
    final sitzung = _sitzung;
    if (sitzung == null || _pos >= sitzung.length) return;
    final fortschritt = AppDaten.von(context).fortschritt;
    final schluessel = sitzung[_pos];
    setState(() {
      if (gewusst) _gewusst++;
      _pos++;
      _umgedreht = false;
    });
    await fortschritt.kartenAntwort(schluessel, gewusst);
  }

  @override
  Widget build(BuildContext context) {
    final sitzung = _sitzung ?? const <String>[];
    final inhalt = AppDaten.von(context).inhalt;

    // Karten ohne passendes Wort (z. B. nach Inhaltsänderung) überspringen
    var pos = _pos;
    while (pos < sitzung.length && inhalt.woerter[sitzung[pos]] == null) {
      pos++;
    }
    final fertig = pos >= sitzung.length;
    final wort = fertig ? null : inhalt.woerter[sitzung[pos]];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Etikett('Wiederholen'),
          const SizedBox(height: Abstand.a8),
          Text('Karten', style: Schriften.anzeige(44)),
          Text(
            fertig ? 'রিভিশন' : '${pos + 1} / ${sitzung.length}',
            style: Schriften.bangla(16),
          ),
          const SizedBox(height: Abstand.a24),
          Expanded(
            child: fertig
                ? _Leer(gesamt: sitzung.length, gewusst: _gewusst)
                : _Karte(
                    key: ValueKey(pos),
                    wort: wort!,
                    umgedreht: _umgedreht,
                    onUmdrehen: () => setState(() {
                      _pos = pos;
                      _umgedreht = !_umgedreht;
                    }),
                  ),
          ),
          if (!fertig) ...[
            const SizedBox(height: Abstand.a16),
            AnimatedOpacity(
              opacity: _umgedreht ? 1 : 0,
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_umgedreht,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Farben.signal,
                          minimumSize: const Size.fromHeight(56),
                          side: const BorderSide(color: Farben.signal, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _antwort(false),
                        child: const Text('Nochmal'),
                      ),
                    ),
                    const SizedBox(width: Abstand.a12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Farben.gruen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _antwort(true),
                        child: const Text('Gewusst'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Karte extends StatelessWidget {
  const _Karte({
    super.key,
    required this.wort,
    required this.umgedreht,
    required this.onUmdrehen,
  });

  final Wort wort;
  final bool umgedreht;
  final VoidCallback onUmdrehen;

  @override
  Widget build(BuildContext context) {
    final ohneAnimation = MediaQuery.disableAnimationsOf(context);
    return Material(
      color: Farben.karte,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Farben.linie),
      ),
      child: InkWell(
        onTap: onUmdrehen,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedSwitcher(
            duration: ohneAnimation ? Duration.zero : const Duration(milliseconds: 220),
            child: umgedreht ? _Rueckseite(wort: wort) : _Vorderseite(wort: wort),
          ),
        ),
      ),
    );
  }
}

class _Vorderseite extends StatelessWidget {
  const _Vorderseite({required this.wort});

  final Wort wort;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('vorne'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Etikett('Deutsch'),
        const SizedBox(height: Abstand.a16),
        Text(wort.de, style: Schriften.anzeige(48)),
        const SizedBox(height: Abstand.a24),
        TonKnopf(text: wort.de),
        const Spacer(),
        Text('Tippen zum Umdrehen · উল্টাতে ট্যাপ করো',
            style: Schriften.bangla(13)),
      ],
    );
  }
}

class _Rueckseite extends StatelessWidget {
  const _Rueckseite({required this.wort});

  final Wort wort;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('hinten'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Etikett('Bedeutung'),
        const SizedBox(height: Abstand.a16),
        Text(wort.bn,
            style: Schriften.bangla(36, farbe: Farben.tinte, gewicht: FontWeight.w600)),
        const SizedBox(height: Abstand.a24),
        if (wort.beispiel.isNotEmpty)
          InkWell(
            onTap: () => SprachDienst.instanz.sprich(wort.beispiel),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Farben.signal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(wort.beispiel, style: Schriften.text(17)),
                        Text(wort.beispielBn, style: Schriften.bangla(14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Leer extends StatelessWidget {
  const _Leer({required this.gesamt, required this.gewusst});

  final int gesamt;
  final int gewusst;

  @override
  Widget build(BuildContext context) {
    final war = gesamt > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Farben.papierDunkel,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            war ? 'Geschafft.' : 'Heute ist nichts fällig.',
            style: Schriften.anzeige(32),
          ),
          const SizedBox(height: Abstand.a8),
          Text(
            war
                ? '$gewusst von $gesamt gewusst. ভুলগুলো কাল আবার আসবে।'
                : 'পাঠ শেষ করলে শব্দগুলো এখানে রিভিশনে আসবে।',
            style: Schriften.bangla(16),
          ),
        ],
      ),
    );
  }
}
