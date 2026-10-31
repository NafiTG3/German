import 'package:flutter/widgets.dart';

import 'package:deutsch_pfad/daten/inhalt_repository.dart';
import 'package:deutsch_pfad/zustand/fortschritt_modell.dart';

class AppDaten extends InheritedWidget {
  const AppDaten({
    super.key,
    required this.inhalt,
    required this.fortschritt,
    required super.child,
  });

  final Inhalt inhalt;
  final FortschrittModell fortschritt;

  static AppDaten von(BuildContext context) {
    final ergebnis = context.dependOnInheritedWidgetOfExactType<AppDaten>();
    assert(ergebnis != null, 'AppDaten fehlt im Widget-Baum');
    return ergebnis!;
  }

  @override
  bool updateShouldNotify(AppDaten alt) =>
      inhalt != alt.inhalt || fortschritt != alt.fortschritt;
}
