import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SprachDienst {
  SprachDienst._();

  static final instanz = SprachDienst._();

  // Für den Hinweis, wenn keine deutsche Stimme installiert ist
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static const _sprachen = ['de-DE', 'de', 'de-AT', 'de-CH'];

  final FlutterTts _tts = FlutterTts();
  bool _bereit = false;
  bool _hinweisGezeigt = false;

  Future<bool> _vorbereiten() async {
    if (_bereit) return true;
    for (final code in _sprachen) {
      try {
        final verfuegbar = await _tts.isLanguageAvailable(code);
        if (verfuegbar == true || verfuegbar == 1) {
          await _tts.setLanguage(code);
          await _tts.setVolume(1.0);
          await _tts.setPitch(1.0);
          _bereit = true;
          return true;
        }
      } catch (_) {
        // nächste Sprachvariante probieren
      }
    }
    return false;
  }

  void _hinweisZeigen() {
    if (_hinweisGezeigt) return;
    _hinweisGezeigt = true;
    messengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 8),
          content: Text(
            'Keine deutsche Stimme gefunden.\n'
            'ফোনের Einstellungen → Text-to-speech (Sprachausgabe) এ গিয়ে জার্মান ভয়েস ডাউনলোড করো, এবং মিডিয়া ভলিউম বাড়াও।',
          ),
        ),
      );
  }

  Future<void> sprich(String text, {bool langsam = false}) async {
    final satz = text.trim();
    if (satz.isEmpty) return;
    try {
      final bereit = await _vorbereiten();
      if (!bereit) {
        _hinweisZeigen();
        // Trotzdem versuchen, falls die Erkennung der Stimme falsch negativ war
        await _tts.setLanguage('de-DE');
        await _tts.setVolume(1.0);
      }
      await _tts.setSpeechRate(langsam ? 0.28 : 0.45);
      await _tts.speak(satz);
    } catch (_) {
      _hinweisZeigen();
    }
  }
}
