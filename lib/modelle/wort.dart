class Wort {
  const Wort({
    required this.de,
    required this.bn,
    required this.beispiel,
    required this.beispielBn,
  });

  final String de;
  final String bn;
  final String beispiel;
  final String beispielBn;

  factory Wort.ausListe(List<dynamic> werte) {
    String feld(int i) => i < werte.length ? '${werte[i] ?? ''}' : '';
    return Wort(de: feld(0), bn: feld(1), beispiel: feld(2), beispielBn: feld(3));
  }
}
