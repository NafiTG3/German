import 'package:deutsch_pfad/modelle/wort.dart';

class Dialogzeile {
  const Dialogzeile({
    required this.sprecher,
    required this.de,
    required this.bn,
  });

  final String sprecher;
  final String de;
  final String bn;

  factory Dialogzeile.ausListe(List<dynamic> werte) {
    String feld(int i) => i < werte.length ? '${werte[i] ?? ''}' : '';
    return Dialogzeile(sprecher: feld(0), de: feld(1), bn: feld(2));
  }
}

class Tag {
  const Tag({
    required this.nummer,
    required this.thema,
    required this.themaBn,
    required this.grammatikTitel,
    required this.grammatikText,
    required this.woerter,
    required this.dialog,
  });

  final int nummer;
  final String thema;
  final String themaBn;
  final String grammatikTitel;
  final String grammatikText;
  final List<Wort> woerter;
  final List<Dialogzeile> dialog;

  factory Tag.ausJson(Map<String, dynamic> json) {
    final grammatik = json['grammatik'] as Map<String, dynamic>? ?? const {};
    return Tag(
      nummer: (json['nr'] as num?)?.toInt() ?? 0,
      thema: json['thema'] as String? ?? '',
      themaBn: json['bn'] as String? ?? '',
      grammatikTitel: grammatik['titel'] as String? ?? '',
      grammatikText: grammatik['text'] as String? ?? '',
      woerter: (json['woerter'] as List<dynamic>? ?? const [])
          .whereType<List<dynamic>>()
          .map(Wort.ausListe)
          .toList(),
      dialog: (json['dialog'] as List<dynamic>? ?? const [])
          .whereType<List<dynamic>>()
          .map(Dialogzeile.ausListe)
          .toList(),
    );
  }
}
