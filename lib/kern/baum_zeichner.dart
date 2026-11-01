import 'dart:ui';

// Gemeinsame Tannen für Landschaft und Hintergrund
abstract final class BaumZeichner {
  static void reihe(
    Canvas canvas,
    Size size,
    Color farbe, {
    required double breite,
    required double hoehe,
    required double basis,
    required double start,
  }) {
    final paint = Paint()..color = farbe;
    var i = 0;
    for (var x = start; x < size.width + breite; x += breite * 0.78) {
      final baumHoehe = hoehe * (0.8 + 0.2 * ((i * 7) % 5) / 4);
      baum(canvas, paint, x, basis, breite, baumHoehe);
      i++;
    }
  }

  static void baum(Canvas canvas, Paint paint, double mitte, double basis,
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
}
