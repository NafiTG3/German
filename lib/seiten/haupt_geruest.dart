import 'package:flutter/material.dart';

import 'package:deutsch_pfad/seiten/plan_seite.dart';
import 'package:deutsch_pfad/seiten/start_seite.dart';
import 'package:deutsch_pfad/seiten/wiederholen_seite.dart';
import 'package:deutsch_pfad/zustand/app_daten.dart';

class HauptGeruest extends StatefulWidget {
  const HauptGeruest({super.key});

  @override
  State<HauptGeruest> createState() => _HauptGeruestZustand();
}

class _HauptGeruestZustand extends State<HauptGeruest> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final fortschritt = AppDaten.von(context).fortschritt;
    // Bewusst ohne IndexedStack: Wiederholen lädt die fälligen Karten bei jedem Besuch neu
    final seiten = <Widget>[
      StartSeite(zumWiederholen: () => setState(() => _tab = 1)),
      const WiederholenSeite(),
      const PlanSeite(),
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: seiten[_tab]),
      bottomNavigationBar: ListenableBuilder(
        listenable: fortschritt,
        builder: (context, _) {
          final faellig = fortschritt.faelligeKarten().length;
          return NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today_rounded),
                label: 'Heute',
              ),
              NavigationDestination(
                icon: Badge(
                  label: Text('$faellig'),
                  isLabelVisible: faellig > 0,
                  child: const Icon(Icons.style_outlined),
                ),
                selectedIcon: Badge(
                  label: Text('$faellig'),
                  isLabelVisible: faellig > 0,
                  child: const Icon(Icons.style_rounded),
                ),
                label: 'Wiederholen',
              ),
              const NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map_rounded),
                label: 'Plan',
              ),
            ],
          );
        },
      ),
    );
  }
}
