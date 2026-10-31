import 'package:deutsch_pfad/kern/konstanten.dart';

class Woche {
  const Woche(this.nummer, this.thema, this.phase, this.fokus);

  final int nummer;
  final String thema;
  final String phase;
  final String fokus;

  int get ersterTag => (nummer - 1) * Konstanten.tageProWoche + 1;
  int get letzterTag => nummer * Konstanten.tageProWoche;
}

abstract final class Lehrplan {
  static const phasen = <String, String>{
    'A1': 'A1 · Grundlagen',
    'A2': 'A2 · Alltag sicher',
    'B1': 'B1 · Prüfungsniveau',
  };

  static const wochen = <Woche>[
    Woche(1, 'Begrüßung & Vorstellung', 'A1', 'Aussprache, sein, W-Fragen, Artikel'),
    Woche(2, 'Zahlen, Zeit & Familie', 'A1', 'Uhrzeit, mein/dein, Akkusativ'),
    Woche(3, 'Essen & Einkaufen', 'A1', 'Modalverben, Mengen, Preise'),
    Woche(4, 'Wohnen & Stadt', 'A1', 'Präpositionen, Wegbeschreibung'),
    Woche(5, 'Arbeit & Beruf', 'A2', 'Berufe, Perfekt mit haben'),
    Woche(6, 'Verkehr & Reisen', 'A2', 'Perfekt mit sein, Dativ'),
    Woche(7, 'Gesundheit & Arzt', 'A2', 'Körper, Termine vereinbaren'),
    Woche(8, 'Freizeit & Pläne', 'A2', 'Nebensätze mit weil und dass'),
    Woche(9, 'Ämter & Wohnung', 'A2', 'Formulare, Briefe, Reflexivverben'),
    Woche(10, 'Bewerbung', 'B1', 'Lebenslauf, Anschreiben'),
    Woche(11, 'Vorstellungsgespräch', 'B1', 'Konjunktiv II, höfliche Bitten'),
    Woche(12, 'Ausbildung & Berufsschule', 'B1', 'Relativsätze, Passiv'),
    Woche(13, 'Meinung & Diskussion', 'B1', 'Argumentieren, Konnektoren'),
    Woche(14, 'Medien & Gesellschaft', 'B1', 'Lesen und Hören, Textverständnis'),
    Woche(15, 'Schreiben & Sprechen', 'B1', 'E-Mails, Präsentation'),
    Woche(16, 'Prüfungstraining', 'B1', 'Modelltests, Zeitmanagement'),
  ];

  static int wocheVonTag(int tag) => ((tag - 1) ~/ Konstanten.tageProWoche) + 1;
}
