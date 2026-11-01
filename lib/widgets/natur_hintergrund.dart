import 'package:flutter/material.dart';

import 'package:deutsch_pfad/kern/baum_zeichner.dart';
import 'package:deutsch_pfad/kern/farben.dart';

// Hintergrund für ganze Seiten: Morgenhimmel, ferne Berge, Hügel und Tannenwald
class NaturSeite extends StatelessWidget {
  const NaturSeite({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const NaturHintergrund(),
        child,
      ],
    );
  }
}

class NaturHintergrund extends StatelessWidget {
  const NaturHintergrund({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(painter: _NaturPainter(), size: Size.infinite),
      ),
    );
  }
}

class _NaturPainter extends CustomPainter {
  const _NaturPainter();

  // Jede Ebene wird deckend gezeichnet und danach mit Transparenz eingeblendet,
  // so entstehen keine dunklen Überlappungen zwischen den Tannen.
  void _ebene(Canvas canvas, Size size, int alpha, void Function() zeichne) {
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = Color.fromARGB(alpha, 255, 255, 255),
    );
    zeichne();
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final b = size.width;
    final h = size.height;
    final flaeche = Offset.zero & size;

    canvas.drawRect(
      flaeche,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Farben.papier, Color(0xFFEFEDDB), Color(0xFFDCE6D2)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(flaeche),
    );

    // Morgensonne
    canvas.drawCircle(Offset(b * 0.84, h * 0.1), 96, Paint()..color = const Color(0x14F2B900));
    canvas.drawCircle(Offset(b * 0.84, h * 0.1), 52, Paint()..color = const Color(0x2EF2B900));

    // Ferne Berge
    _ebene(canvas, size, 0x2E, () {
      final berge = Path()
        ..moveTo(0, h * 0.8)
        ..lineTo(b * 0.16, h * 0.7)
        ..lineTo(b * 0.3, h * 0.77)
        ..lineTo(b * 0.5, h * 0.65)
        ..lineTo(b * 0.69, h * 0.78)
        ..lineTo(b * 0.85, h * 0.71)
        ..lineTo(b, h * 0.79)
        ..lineTo(b, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(berge, Paint()..color = Farben.tanneMittel);
    });

    // Sanfte Hügel
    _ebene(canvas, size, 0x38, () {
      final huegel = Path()
        ..moveTo(0, h * 0.86)
        ..quadraticBezierTo(b * 0.28, h * 0.74, b * 0.55, h * 0.85)
        ..quadraticBezierTo(b * 0.8, h * 0.95, b, h * 0.82)
        ..lineTo(b, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(huegel, Paint()..color = Farben.tanne);
    });

    // Tannenwald, hintere und vordere Reihe
    _ebene(canvas, size, 0x44, () {
      BaumZeichner.reihe(canvas, size, Farben.tanneTief,
          breite: 34, hoehe: 90, basis: h * 0.95, start: -12);
    });
    _ebene(canvas, size, 0x52, () {
      BaumZeichner.reihe(canvas, size, Farben.tanneDunkel,
          breite: 52, hoehe: 130, basis: h + 6, start: 10);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter alt) => false;
}
