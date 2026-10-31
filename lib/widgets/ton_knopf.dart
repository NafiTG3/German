import 'package:flutter/material.dart';

import 'package:deutsch_pfad/dienste/sprach_dienst.dart';
import 'package:deutsch_pfad/kern/farben.dart';

// Tippen: normal vorlesen. Lange drücken: langsam vorlesen.
class TonKnopf extends StatelessWidget {
  const TonKnopf({super.key, required this.text, this.gross = false});

  final String text;
  final bool gross;

  @override
  Widget build(BuildContext context) {
    final groesse = gross ? 72.0 : 48.0;
    return Tooltip(
      message: 'Vorlesen (lange drücken: langsam)',
      child: Material(
        color: Farben.signal,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => SprachDienst.instanz.sprich(text),
          onLongPress: () => SprachDienst.instanz.sprich(text, langsam: true),
          child: SizedBox(
            width: groesse,
            height: groesse,
            child: Icon(
              Icons.volume_up_rounded,
              size: gross ? 36 : 24,
              color: Colors.white,
              semanticLabel: 'Vorlesen: $text',
            ),
          ),
        ),
      ),
    );
  }
}
