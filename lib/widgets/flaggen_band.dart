import 'package:flutter/material.dart';

import 'package:deutsch_pfad/kern/farben.dart';

// Schmaler Streifen in Schwarz, Rot, Gold
class FlaggenBand extends StatelessWidget {
  const FlaggenBand({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: Column(
        children: [
          SizedBox(height: 3, width: double.infinity, child: ColoredBox(color: Farben.flaggeSchwarz)),
          SizedBox(height: 3, width: double.infinity, child: ColoredBox(color: Farben.flaggeRot)),
          SizedBox(height: 3, width: double.infinity, child: ColoredBox(color: Farben.gold)),
        ],
      ),
    );
  }
}
