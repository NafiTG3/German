import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FortschrittSpeicher {
  static const _schluessel = 'fortschritt_v1';

  Future<Map<String, dynamic>> lesen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roh = prefs.getString(_schluessel);
      if (roh == null) return {};
      final daten = jsonDecode(roh);
      return daten is Map<String, dynamic> ? daten : {};
    } catch (_) {
      return {};
    }
  }

  Future<void> schreiben(Map<String, dynamic> daten) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_schluessel, jsonEncode(daten));
    } catch (_) {
      // Speichern ist optional, die App läuft auch ohne
    }
  }
}
