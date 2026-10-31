import 'package:flutter/material.dart';

import 'package:deutsch_pfad/kern/farben.dart';
import 'package:deutsch_pfad/kern/schriften.dart';

class Etikett extends StatelessWidget {
  const Etikett(this.text, {super.key, this.farbe = Farben.tinteGedaempft});

  final String text;
  final Color farbe;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: Schriften.text(
          12,
          farbe: farbe,
          gewicht: FontWeight.w700,
          abstand: 1.4,
        ),
      );
}
