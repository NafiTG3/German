import 'package:flutter/material.dart';

import 'package:deutsch_pfad/kern/abstand.dart';
import 'package:deutsch_pfad/kern/farben.dart';
import 'package:deutsch_pfad/kern/schriften.dart';
import 'package:deutsch_pfad/widgets/etikett.dart';
import 'package:deutsch_pfad/widgets/flaggen_band.dart';
import 'package:deutsch_pfad/widgets/tannen_landschaft.dart';
import 'package:deutsch_pfad/widgets/ton_knopf.dart';

class EinfuehrungSeite extends StatefulWidget {
  const EinfuehrungSeite({super.key, required this.onFertig});

  final VoidCallback onFertig;

  @override
  State<EinfuehrungSeite> createState() => _EinfuehrungSeiteZustand();
}

class _Folie {
  const _Folie({required this.visual, required this.titel, required this.bn});

  final Widget visual;
  final String titel;
  final String bn;
}

class _EinfuehrungSeiteZustand extends State<EinfuehrungSeite> {
  final _controller = PageController();
  int _seite = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _riesig(String text, {Color farbe = Farben.tinte, double groesse = 120}) =>
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: Schriften.anzeige(groesse,
              farbe: farbe, gewicht: FontWeight.w300, hoehe: 1),
        ),
      );

  Widget _landschaft() => ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 240,
          width: double.infinity,
          color: Farben.tanne,
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 150,
                child: TannenLandschaft(),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Hallo',
                  style: Schriften.anzeige(72,
                      farbe: Farben.papier, gewicht: FontWeight.w300),
                ),
              ),
            ],
          ),
        ),
      );

  List<_Folie> _folien() => [
        _Folie(
          visual: _landschaft(),
          titel: 'Willkommen.',
          bn: 'জার্মানিতে আউসবিল্ডুং-এর স্বপ্ন এখান থেকেই শুরু। প্রতিদিন একটু একটু করে জার্মান শেখো, নিজের ভাষা বাংলায় বুঝে।',
        ),
        _Folie(
          visual: _riesig('112'),
          titel: '112 Tage. 16 Wochen.',
          bn: '১১২ দিনের পরিকল্পনা। ধাপে ধাপে A1, তারপর A2, শেষে B1 পরীক্ষার স্তর।',
        ),
        _Folie(
          visual: _riesig('1 Tag', farbe: Farben.signal),
          titel: 'Jeden Tag eine Lektion.',
          bn: 'প্রতিদিন একটি পাঠ: নতুন শব্দ, বাংলায় ব্যাকরণ, দৈনন্দিন কথোপকথন এবং শেষে ছোট কুইজ।',
        ),
        _Folie(
          visual: const Align(
            alignment: Alignment.centerLeft,
            child: TonKnopf(text: 'Hallo, ich lerne Deutsch.', gross: true),
          ),
          titel: 'Hören und sprechen.',
          bn: 'স্পিকার বাটনে ট্যাপ করে সঠিক উচ্চারণ শোনো। লম্বা চাপলে ধীরে শোনা যাবে। প্রতিটি শব্দ জোরে বলে অভ্যাস করো।',
        ),
        _Folie(
          visual: _riesig('70 %'),
          titel: 'Üben und bestehen.',
          bn: 'কুইজে ৭০% বা বেশি পেলে দিনটি সম্পূর্ণ হয়। কম হলে যতবার খুশি আবার চেষ্টা করতে পারবে।',
        ),
        _Folie(
          visual: _riesig('1 · 2 · 4 · 8 · 16', groesse: 56, farbe: Farben.signal),
          titel: 'Wiederholen.',
          bn: 'শেখা শব্দ ১, ২, ৪, ৮, ১৬ দিন পরপর রিভিশনে আসে। "Wiederholen" ট্যাব নিয়মিত খুলো, তাতে শব্দ মনে থাকে।',
        ),
        _Folie(
          visual: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                style: Schriften.anzeige(56, gewicht: FontWeight.w400),
                children: const [
                  TextSpan(text: 'der '),
                  TextSpan(text: 'die ', style: TextStyle(color: Farben.signal)),
                  TextSpan(text: 'das', style: TextStyle(color: Farben.gruen)),
                ],
              ),
            ),
          ),
          titel: 'Immer mit Artikel.',
          bn: 'জার্মানে প্রতিটি শব্দের লিঙ্গ আছে। তাই শব্দ সবসময় der, die বা das সহ মুখস্থ করো, যেমন: der Tisch।',
        ),
        _Folie(
          visual: _riesig('B1', farbe: Farben.signal, groesse: 140),
          titel: 'Dein Ziel: B1.',
          bn: 'চার মাসে B1 পাশ করতে প্রতিদিন নিয়মিত সময় দিতে হবে (আনুমানিক ৩–৪ ঘণ্টা, শোনা ও বলা সহ)। এক দিনও বাদ দিও না। চলো শুরু করি!',
        ),
      ];

  void _weiter(int anzahl) {
    if (_seite + 1 >= anzahl) {
      widget.onFertig();
      return;
    }
    final ohneAnimation = MediaQuery.disableAnimationsOf(context);
    _controller.nextPage(
      duration: ohneAnimation ? Duration.zero : const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final folien = _folien();
    final letzte = _seite == folien.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const FlaggenBand(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 8, 0),
              child: Row(
                children: [
                  Etikett('${_seite + 1} / ${folien.length}'),
                  const Spacer(),
                  Visibility(
                    visible: !letzte,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed: widget.onFertig,
                      child: Text('Überspringen',
                          style: Schriften.text(14,
                              farbe: Farben.tinteGedaempft,
                              gewicht: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: folien.length,
                onPageChanged: (i) => setState(() => _seite = i),
                itemBuilder: (context, i) {
                  final f = folien[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: f.visual,
                          ),
                        ),
                        Text(f.titel, style: Schriften.anzeige(40)),
                        const SizedBox(height: Abstand.a12),
                        Text(f.bn,
                            style: Schriften.bangla(17,
                                farbe: Farben.tinteGedaempft)),
                        const SizedBox(height: Abstand.a24),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: [
                  for (var i = 0; i < folien.length; i++)
                    AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _seite ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _seite ? Farben.signal : Farben.papierDunkel,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Farben.signal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(140, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: Schriften.text(16, gewicht: FontWeight.w700),
                    ),
                    onPressed: () => _weiter(folien.length),
                    child: Text(letzte ? "Los geht's" : 'Weiter'),
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
