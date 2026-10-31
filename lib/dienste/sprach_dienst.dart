import 'package:flutter_tts/flutter_tts.dart';

class SprachDienst {
  SprachDienst._();

  static final instanz = SprachDienst._();

  final FlutterTts _tts = FlutterTts();
  bool _bereit = false;

  Future<void> _vorbereiten() async {
    if (_bereit) return;
    await _tts.setLanguage('de-DE');
    await _tts.setPitch(1.0);
    _bereit = true;
  }

  Future<void> sprich(String text, {bool langsam = false}) async {
    if (text.trim().isEmpty) return;
    try {
      await _vorbereiten();
      await _tts.setSpeechRate(langsam ? 0.28 : 0.45);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // Ohne Sprachausgabe bleibt die App nutzbar
    }
  }
}
