import 'package:flutter/material.dart';

import 'package:deutsch_pfad/kern/baum_zeichner.dart';
import 'package:deutsch_pfad/kern/farben.dart';

// Schwarzwald: Hügel und zwei Reihen Tannen, gezeichnet ohne Bilddateien
class TannenLandschaft extends StatelessWidget {
  const TannenLandschaft({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(painter: _TannenPainter(), size: Size.infinite),
      ),
    );
  }
}

class _TannenPainter extends CustomPainter {
  const _TannenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final b = size.width;
    final h = size.height;

    final huegel = Path()
      ..moveTo(0, h * 0.7)
      ..quadraticBezierTo(b * 0.25, h * 0.3, b * 0.5, h * 0.6)
      ..quadraticBezierTo(b * 0.78, h * 0.92, b, h * 0.45)
      ..lineTo(b, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(huegel, Paint()..color = Farben.tanneMittel);

    BaumZeichner.reihe(canvas, size, Farben.tanneTief,
        breite: 30, hoehe: 70, basis: h * 0.92, start: -10);
    BaumZeichner.reihe(canvas, size, Farben.tanneDunkel,
        breite: 46, hoehe: 104, basis: h + 4, start: 14);
  }

  @override
  bool shouldRepaint(covariant CustomPainter alt) => false;
}
