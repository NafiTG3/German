import 'dart:async';

import 'package:flutter/material.dart';

import 'package:deutsch_pfad/daten/fortschritt_speicher.dart';
import 'package:deutsch_pfad/daten/inhalt_repository.dart';
import 'package:deutsch_pfad/dienste/erinnerungs_dienst.dart';
import 'package:deutsch_pfad/dienste/sprach_dienst.dart';
import 'package:deutsch_pfad/kern/farben.dart';
import 'package:deutsch_pfad/kern/schriften.dart';
import 'package:deutsch_pfad/kern/thema.dart';
import 'package:deutsch_pfad/seiten/einfuehrung_seite.dart';
import 'package:deutsch_pfad/seiten/haupt_geruest.dart';
import 'package:deutsch_pfad/zustand/app_daten.dart';
import 'package:deutsch_pfad/zustand/fortschritt_modell.dart';

class DeutschPfadApp extends StatefulWidget {
  const DeutschPfadApp({super.key});

  @override
  State<DeutschPfadApp> createState() => _DeutschPfadAppZustand();
}

class _DeutschPfadAppZustand extends State<DeutschPfadApp> {
  final _speicher = FortschrittSpeicher();
  Inhalt? _inhalt;
  FortschrittModell? _fortschritt;
  bool _einfuehrungGesehen = true;
  Object? _fehler;

  void _einfuehrungAbschliessen() {
    setState(() => _einfuehrungGesehen = true);
    _speicher.einfuehrungMarkieren();
    unawaited(ErinnerungsDienst.starten());
  }

  @override
  void initState() {
    super.initState();
    _starten();
  }

  Future<void> _starten() async {
    setState(() => _fehler = null);
    try {
      final modell = FortschrittModell(_speicher);
      // Inhalt, Fortschritt und Einführungsstatus unabhängig voneinander parallel laden
      final ergebnis = await Future.wait<Object>([
        InhaltRepository.laden(),
        modell.laden().then((_) => modell),
        _speicher.einfuehrungGesehen(),
      ]);
      if (!mounted) return;
      setState(() {
        _inhalt = ergebnis[0] as Inhalt;
        _fortschritt = ergebnis[1] as FortschrittModell;
        _einfuehrungGesehen = ergebnis[2] as bool;
      });
      // Stimme im Hintergrund vorbereiten, Erinnerungen erst nach der Einführung
      unawaited(SprachDienst.instanz.vorwaermen());
      if (_einfuehrungGesehen) unawaited(ErinnerungsDienst.starten());
    } catch (e) {
      if (!mounted) return;
      setState(() => _fehler = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inhalt = _inhalt;
    final fortschritt = _fortschritt;
    final bereit = inhalt != null && fortschritt != null;
    return MaterialApp(
      title: 'Umlaut',
      debugShowCheckedModeBanner: false,
      theme: baueThema(),
      scaffoldMessengerKey: SprachDienst.messengerKey,
      home: bereit
          ? (_einfuehrungGesehen
              ? const HauptGeruest()
              : EinfuehrungSeite(onFertig: _einfuehrungAbschliessen))
          : _Ladebild(fehler: _fehler, erneut: _starten),
      builder: (context, kind) => (inhalt != null && fortschritt != null)
          ? AppDaten(inhalt: inhalt, fortschritt: fortschritt, child: kind!)
          : kind!,
    );
  }
}

class _Ladebild extends StatelessWidget {
  const _Ladebild({required this.fehler, required this.erneut});

  final Object? fehler;
  final VoidCallback erneut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: fehler == null
            ? Text('Umlaut', style: Schriften.anzeige(36))
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Etwas ist schiefgelaufen.',
                        style: Schriften.anzeige(24)),
                    const SizedBox(height: 8),
                    Text('কিছু একটা সমস্যা হয়েছে।', style: Schriften.bangla(16)),
                    const SizedBox(height: 24),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Farben.signal,
                        minimumSize: const Size(160, 48),
                      ),
                      onPressed: erneut,
                      child: const Text('Nochmal versuchen'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
