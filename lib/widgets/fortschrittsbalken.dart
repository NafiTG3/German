import 'package:flutter/material.dart';

import 'package:deutsch_pfad/kern/farben.dart';

class Fortschrittsbalken extends StatelessWidget {
  const Fortschrittsbalken({
    super.key,
    required this.wert,
    this.hoehe = 8,
    this.farbe = Farben.signal,
  });

  final double wert;
  final double hoehe;
  final Color farbe;

  @override
  Widget build(BuildContext context) {
    final begrenzt = wert.isNaN ? 0.0 : wert.clamp(0.0, 1.0).toDouble();
    final ohneAnimation = MediaQuery.disableAnimationsOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(hoehe),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: begrenzt),
        duration: ohneAnimation ? Duration.zero : const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => LinearProgressIndicator(
          value: v,
          minHeight: hoehe,
          backgroundColor: Farben.papierDunkel,
          valueColor: AlwaysStoppedAnimation<Color>(farbe),
        ),
      ),
    );
  }
}
