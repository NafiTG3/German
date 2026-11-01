import 'package:flutter/material.dart';

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

    _reihe(canvas, size, Farben.tanneTief,
        breite: 30, hoehe: 70, basis: h * 0.92, start: -10);
    _reihe(canvas, size, Farben.tanneDunkel,
        breite: 46, hoehe: 104, basis: h + 4, start: 14);
  }

  void _reihe(
    Canvas canvas,
    Size size, Color farbe, {
    required double breite,
    required double hoehe,
    required double basis,
    required double start,
  }) {
    final paint = Paint()..color = farbe;
    var i = 0;
    for (var x = start; x < size.width + breite; x += breite * 0.78) {
      final baumHoehe = hoehe * (0.8 + 0.2 * ((i * 7) % 5) / 4);
      _baum(canvas, paint, x, basis, breite, baumHoehe);
      i++;
    }
  }

  void _baum(Canvas canvas, Paint paint, double mitte, double basis,
      double breite, double hoehe) {
    for (var k = 0; k < 3; k++) {
      final spitze = basis - hoehe + k * hoehe * 0.26;
      final boden = spitze + hoehe * 0.46;
      final halb = breite * (0.30 + 0.10 * k);
      canvas.drawPath(
        Path()
          ..moveTo(mitte, spitze)
          ..lineTo(mitte + halb, boden)
          ..lineTo(mitte - halb, boden)
          ..close(),
        paint,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(mitte - breite * 0.05, basis - hoehe * 0.1, breite * 0.1, hoehe * 0.1 + 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter alt) => false;
}
