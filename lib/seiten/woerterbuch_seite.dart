import 'package:flutter/material.dart';

import 'package:deutsch_pfad/daten/aufgaben_generator.dart';
import 'package:deutsch_pfad/dienste/sprach_dienst.dart';
import 'package:deutsch_pfad/kern/abstand.dart';
import 'package:deutsch_pfad/kern/farben.dart';
import 'package:deutsch_pfad/kern/schriften.dart';
import 'package:deutsch_pfad/modelle/wort.dart';
import 'package:deutsch_pfad/widgets/etikett.dart';
import 'package:deutsch_pfad/zustand/app_daten.dart';

class WoerterbuchSeite extends StatefulWidget {
  const WoerterbuchSeite({super.key});

  @override
  State<WoerterbuchSeite> createState() => _WoerterbuchSeiteZustand();
}

class _WoerterbuchSeiteZustand extends State<WoerterbuchSeite> {
  final _suche = TextEditingController();
  final _aussprache = TextEditingController();
  final List<String> _verlauf = [];
  int _modus = 0;

  @override
  void dispose() {
    _suche.dispose();
    _aussprache.dispose();
    super.dispose();
  }

  static int _vergleich(Wort a, Wort b) => AufgabenGenerator.kern(a.de)
      .toLowerCase()
      .compareTo(AufgabenGenerator.kern(b.de).toLowerCase());

  List<Wort> _filtern(List<Wort> alle, String eingabe) {
    final q = eingabe.trim().toLowerCase();
    if (q.isEmpty) return alle;
    return alle
        .where((w) =>
            w.de.toLowerCase().contains(q) || w.bn.toLowerCase().contains(q))
        .toList();
  }

  void _sprechen(String text, {bool langsam = false}) {
    final satz = text.trim();
    if (satz.isEmpty) return;
    setState(() {
      _verlauf.remove(satz);
      _verlauf.insert(0, satz);
      if (_verlauf.length > 6) _verlauf.removeLast();
    });
    SprachDienst.instanz.sprich(satz, langsam: langsam);
  }

  InputDecoration _feld(String hinweis, TextEditingController c) =>
      InputDecoration(
        hintText: hinweis,
        hintStyle: Schriften.text(16, farbe: Farben.tinteGedaempft),
        filled: true,
        fillColor: Farben.karte,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: c.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Löschen',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(c.clear),
              ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Farben.linie),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Farben.linie),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Farben.tanne, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final alle = AppDaten.von(context).inhalt.alleWoerter..sort(_vergleich);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Etikett('Nachschlagen'),
          const SizedBox(height: Abstand.a8),
          Text('Wörterbuch', style: Schriften.anzeige(44)),
          Text('${alle.length}টি শব্দ · জার্মান ও বাংলা',
              style: Schriften.bangla(16)),
          const SizedBox(height: Abstand.a16),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 0, label: Text('Wörter')),
                ButtonSegment(value: 1, label: Text('Aussprache')),
              ],
              selected: {_modus},
              onSelectionChanged: (s) => setState(() => _modus = s.first),
              style: SegmentedButton.styleFrom(
                backgroundColor: Farben.karte,
                foregroundColor: Farben.tinte,
                selectedBackgroundColor: Farben.tanne,
                selectedForegroundColor: Colors.white,
                side: const BorderSide(color: Farben.linie),
                textStyle: Schriften.text(14, gewicht: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: Abstand.a16),
          Expanded(
            child: _modus == 0 ? _verzeichnis(alle) : _ausspracheBereich(alle),
          ),
        ],
      ),
    );
  }

  Widget _verzeichnis(List<Wort> alle) {
    final treffer = _filtern(alle, _suche.text);
    return Column(
      children: [
        TextField(
          controller: _suche,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          decoration: _feld('Deutsch oder বাংলা suchen', _suche),
        ),
        const SizedBox(height: Abstand.a16),
        Row(
          children: [
            const Expanded(flex: 5, child: Etikett('Deutsch')),
            Expanded(
              flex: 4,
              child: Text('বাংলা অর্থ',
                  style: Schriften.bangla(12,
                      farbe: Farben.tinteGedaempft, gewicht: FontWeight.w700)),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const Divider(height: 16, color: Farben.linie),
        Expanded(
          child: treffer.isEmpty
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: Abstand.a24),
                    child: Text('Nichts gefunden. কিছু পাওয়া যায়নি।',
                        style: Schriften.bangla(16)),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: Abstand.a24),
                  itemCount: treffer.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Farben.linie),
                  itemBuilder: (context, i) => _Zeile(wort: treffer[i]),
                ),
        ),
      ],
    );
  }

  Widget _ausspracheBereich(List<Wort> alle) {
    final text = _aussprache.text;
    final vorschlaege = text.trim().isEmpty
        ? const <Wort>[]
        : _filtern(alle, text).take(8).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: Abstand.a24),
      children: [
        TextField(
          controller: _aussprache,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          onSubmitted: _sprechen,
          decoration: _feld('Deutsches Wort eingeben', _aussprache),
        ),
        const SizedBox(height: Abstand.a12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Farben.signal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: text.trim().isEmpty ? null : () => _sprechen(text),
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text('Anhören'),
              ),
            ),
            const SizedBox(width: Abstand.a12),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Farben.tinte,
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: Farben.tinte),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: text.trim().isEmpty
                    ? null
                    : () => _sprechen(text, langsam: true),
                icon: const Icon(Icons.slow_motion_video_rounded),
                label: const Text('Langsam'),
              ),
            ),
          ],
        ),
        if (text.trim().isNotEmpty && vorschlaege.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Abstand.a16),
            child: Text(
              'ডিকশনারিতে নেই, তবু "Anhören" চাপলে উচ্চারণ শুনতে পারবে।',
              style: Schriften.bangla(14),
            ),
          ),
        if (vorschlaege.isNotEmpty) ...[
          const SizedBox(height: Abstand.a24),
          const Etikett('Treffer'),
          const SizedBox(height: Abstand.a8),
          for (final w in vorschlaege) ...[
            _Zeile(wort: w),
            const Divider(height: 1, color: Farben.linie),
          ],
        ],
        if (_verlauf.isNotEmpty) ...[
          const SizedBox(height: Abstand.a24),
          const Etikett('Zuletzt gehört'),
          const SizedBox(height: Abstand.a8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in _verlauf)
                ActionChip(
                  label: Text(v, style: Schriften.text(14)),
                  backgroundColor: Farben.papierDunkel,
                  side: BorderSide.none,
                  onPressed: () {
                    _aussprache.text = v;
                    _sprechen(v);
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile({required this.wort});

  final Wort wort;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${wort.de}, ${wort.bn}. Vorlesen',
      child: InkWell(
        onTap: () => SprachDienst.instanz.sprich(wort.de),
        onLongPress: () => SprachDienst.instanz.sprich(wort.de, langsam: true),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(wort.de, style: Schriften.anzeige(20)),
                ),
                Expanded(
                  flex: 4,
                  child: Text(wort.bn,
                      style: Schriften.bangla(16, farbe: Farben.tinte)),
                ),
                const SizedBox(
                  width: 48,
                  child: Icon(Icons.volume_up_rounded, color: Farben.signal),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
