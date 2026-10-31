import 'package:flutter/material.dart';

import 'package:deutsch_pfad/daten/aufgaben_generator.dart';
import 'package:deutsch_pfad/dienste/sprach_dienst.dart';
import 'package:deutsch_pfad/kern/abstand.dart';
import 'package:deutsch_pfad/kern/farben.dart';
import 'package:deutsch_pfad/kern/konstanten.dart';
import 'package:deutsch_pfad/kern/schriften.dart';
import 'package:deutsch_pfad/modelle/aufgabe.dart';
import 'package:deutsch_pfad/modelle/tag.dart';
import 'package:deutsch_pfad/widgets/etikett.dart';
import 'package:deutsch_pfad/widgets/fortschrittsbalken.dart';
import 'package:deutsch_pfad/widgets/ton_knopf.dart';
import 'package:deutsch_pfad/zustand/app_daten.dart';

class UebungSeite extends StatefulWidget {
  const UebungSeite({super.key, required this.tag});

  final Tag tag;

  @override
  State<UebungSeite> createState() => _UebungSeiteZustand();
}

class _UebungSeiteZustand extends State<UebungSeite> {
  List<Aufgabe>? _aufgaben;
  int _index = 0;
  int? _gewaehlt;
  int _richtig = 0;
  bool _fertig = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_aufgaben == null) _starten();
  }

  void _starten() {
    final inhalt = AppDaten.von(context).inhalt;
    _aufgaben = AufgabenGenerator.erzeuge(widget.tag, inhalt.alleWoerter);
    _index = 0;
    _gewaehlt = null;
    _richtig = 0;
    _fertig = false;
    _autoVorlesen();
  }

  Aufgabe? get _aufgabe {
    final liste = _aufgaben;
    if (liste == null || _index >= liste.length) return null;
    return liste[_index];
  }

  void _autoVorlesen() {
    final a = _aufgabe;
    if (a != null && a.art == AufgabenArt.hoeren && a.vorlesen != null) {
      SprachDienst.instanz.sprich(a.vorlesen!);
    }
  }

  void _waehlen(int i) {
    final a = _aufgabe;
    if (a == null || _gewaehlt != null) return;
    setState(() {
      _gewaehlt = i;
      if (i == a.richtig) _richtig++;
    });
    if (a.art != AufgabenArt.hoeren && a.vorlesen != null) {
      SprachDienst.instanz.sprich(a.vorlesen!);
    }
  }

  Future<void> _weiter() async {
    final liste = _aufgaben;
    if (liste == null) return;
    if (_index + 1 < liste.length) {
      setState(() {
        _index++;
        _gewaehlt = null;
      });
      _autoVorlesen();
      return;
    }
    final fortschritt = AppDaten.von(context).fortschritt;
    final prozent = (_richtig * 100 / liste.length).round();
    await fortschritt.tagAbschliessen(widget.tag, prozent);
    if (!mounted) return;
    setState(() => _fertig = true);
  }

  @override
  Widget build(BuildContext context) {
    final liste = _aufgaben ?? const <Aufgabe>[];
    if (liste.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('Keine Aufgaben für diesen Tag.',
              style: Schriften.text(16)),
        ),
      );
    }
    if (_fertig) return _Ergebnis(
      prozent: (_richtig * 100 / liste.length).round(),
      richtig: _richtig,
      gesamt: liste.length,
      nochmal: () => setState(_starten),
    );

    final a = liste[_index];
    final gewaehlt = _gewaehlt;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Schließen',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Fortschrittsbalken(wert: _index / liste.length),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${_index + 1}/${liste.length}',
                  style: Schriften.text(13, farbe: Farben.tinteGedaempft)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Etikett(_anweisung(a.art).$1),
          Text(_anweisung(a.art).$2, style: Schriften.bangla(14)),
          const SizedBox(height: Abstand.a24),
          _Frage(aufgabe: a),
          const SizedBox(height: Abstand.a32),
          for (var i = 0; i < a.optionen.length; i++)
            _OptionKachel(
              text: a.optionen[i],
              bangla: a.art == AufgabenArt.deZuBn,
              zustand: gewaehlt == null
                  ? _OptionZustand.offen
                  : (i == a.richtig
                      ? _OptionZustand.richtig
                      : (i == gewaehlt
                          ? _OptionZustand.falsch
                          : _OptionZustand.gedimmt)),
              onTap: () => _waehlen(i),
            ),
        ],
      ),
      bottomNavigationBar: gewaehlt == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gewaehlt == a.richtig
                          ? 'Richtig!'
                          : 'Nicht ganz. Richtig: ${a.richtigeAntwort}',
                      style: Schriften.text(
                        16,
                        gewicht: FontWeight.w700,
                        farbe: gewaehlt == a.richtig
                            ? Farben.gruen
                            : Farben.signal,
                      ),
                    ),
                    const SizedBox(height: Abstand.a12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Farben.tinte,
                        foregroundColor: Farben.papier,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: Schriften.text(16, gewicht: FontWeight.w700),
                      ),
                      onPressed: _weiter,
                      child: Text(_index + 1 == liste.length ? 'Fertig' : 'Weiter'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  (String, String) _anweisung(AufgabenArt art) => switch (art) {
        AufgabenArt.deZuBn => ('Was bedeutet das?', 'এর অর্থ কী?'),
        AufgabenArt.bnZuDe => ('Wie sagt man das auf Deutsch?', 'জার্মানে কী বলে?'),
        AufgabenArt.luecke => ('Ergänze den Satz', 'বাক্যটি পূর্ণ করো'),
        AufgabenArt.hoeren => ('Was hörst du?', 'কী শুনলে?'),
      };
}

class _Frage extends StatelessWidget {
  const _Frage({required this.aufgabe});

  final Aufgabe aufgabe;

  @override
  Widget build(BuildContext context) {
    switch (aufgabe.art) {
      case AufgabenArt.deZuBn:
        return Row(
          children: [
            Expanded(child: Text(aufgabe.frage, style: Schriften.anzeige(36))),
            TonKnopf(text: aufgabe.frage),
          ],
        );
      case AufgabenArt.bnZuDe:
        return Text(aufgabe.frage,
            style: Schriften.bangla(32, farbe: Farben.tinte, gewicht: FontWeight.w600));
      case AufgabenArt.luecke:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(aufgabe.frage, style: Schriften.anzeige(28, gewicht: FontWeight.w500)),
            const SizedBox(height: Abstand.a8),
            Text(aufgabe.hinweis ?? '', style: Schriften.bangla(16)),
          ],
        );
      case AufgabenArt.hoeren:
        return Center(
          child: TonKnopf(text: aufgabe.vorlesen ?? '', gross: true),
        );
    }
  }
}

enum _OptionZustand { offen, richtig, falsch, gedimmt }

class _OptionKachel extends StatelessWidget {
  const _OptionKachel({
    required this.text,
    required this.bangla,
    required this.zustand,
    required this.onTap,
  });

  final String text;
  final bool bangla;
  final _OptionZustand zustand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (Color fuellung, Color rand, IconData? symbol) = switch (zustand) {
      _OptionZustand.richtig => (Farben.gruenHell, Farben.gruen, Icons.check_circle_rounded),
      _OptionZustand.falsch => (Farben.rotHell, Farben.signal, Icons.cancel_rounded),
      _ => (Farben.karte, Farben.linie, null),
    };
    final gedimmt = zustand == _OptionZustand.gedimmt;
    final stil = bangla
        ? Schriften.bangla(18, farbe: Farben.tinte, gewicht: FontWeight.w500)
        : Schriften.text(18, gewicht: FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.only(bottom: Abstand.a12),
      child: Opacity(
        opacity: gedimmt ? 0.5 : 1,
        child: Material(
          color: fuellung,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: rand, width: 1.5),
          ),
          child: InkWell(
            onTap: zustand == _OptionZustand.offen ? onTap : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Expanded(child: Text(text, style: stil)),
                    if (symbol != null) Icon(symbol, color: rand),
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

class _Ergebnis extends StatelessWidget {
  const _Ergebnis({
    required this.prozent,
    required this.richtig,
    required this.gesamt,
    required this.nochmal,
  });

  final int prozent;
  final int richtig;
  final int gesamt;
  final VoidCallback nochmal;

  @override
  Widget build(BuildContext context) {
    final bestanden = prozent >= Konstanten.bestehensGrenze;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Etikett(bestanden ? 'Tag erledigt' : 'Noch nicht ganz'),
              Text('$prozent %',
                  style: Schriften.anzeige(112,
                      gewicht: FontWeight.w300,
                      farbe: bestanden ? Farben.gruen : Farben.signal,
                      hoehe: 1)),
              Text('$richtig von $gesamt richtig',
                  style: Schriften.anzeige(24)),
              const SizedBox(height: Abstand.a8),
              Text(
                bestanden
                    ? 'অভিনন্দন! আজকের পাঠ সম্পূর্ণ, শব্দগুলো রিভিশনে যোগ হয়েছে।'
                    : '${Konstanten.bestehensGrenze}% এর বেশি হলে দিনটি সম্পূর্ণ হবে। আবার চেষ্টা করো।',
                style: Schriften.bangla(16),
              ),
              const Spacer(),
              if (!bestanden)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Farben.signal,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: nochmal,
                  child: const Text('Nochmal'),
                ),
              const SizedBox(height: Abstand.a12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Farben.tinte,
                  minimumSize: const Size.fromHeight(56),
                  side: const BorderSide(color: Farben.tinte),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(bestanden ? 'Fertig' : 'Zurück zur Lektion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
