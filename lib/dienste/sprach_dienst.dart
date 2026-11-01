import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:deutsch_pfad/dienste/stimme_motor.dart';

// Erst die eingebaute männliche Stimme (offline), sonst die Stimme des Telefons
class SprachDienst {
  SprachDienst._();

  static final instanz = SprachDienst._();

  // Für Hinweise, wenn keine Stimme verfügbar ist
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static const _sprachen = ['de-DE', 'de', 'de-AT', 'de-CH'];

  final FlutterTts _tts = FlutterTts();
  AudioPlayer? _spieler;
  int _auftrag = 0;
  bool _systemBereit = false;
  bool _hinweisGezeigt = false;
  bool _vorbereitungGezeigt = false;

  // Beim App Start aufrufen, damit die Stimme beim ersten Tippen schon bereit ist
  Future<void> vorwaermen() => StimmeMotor.instanz.bereit();

  Future<void> sprich(String text, {bool langsam = false}) async {
    final satz = text.trim();
    if (satz.isEmpty) return;
    final meiner = ++_auftrag;
    final motor = StimmeMotor.instanz;

    try {
      if (motor.fertig == null) _vorbereitungZeigen();
      if (await motor.bereit()) {
        final pfad = await motor.erzeuge(satz, langsam: langsam);
        if (meiner != _auftrag) return;
        if (pfad != null) {
          final spieler = _spieler ??= AudioPlayer();
          await spieler.stop();
          await spieler.play(DeviceFileSource(pfad));
          return;
        }
      }
    } catch (_) {
      // weiter mit der Stimme des Telefons
    }
    if (meiner != _auftrag) return;
    await _systemSprich(satz, langsam: langsam);
  }

  Future<bool> _systemVorbereiten() async {
    if (_systemBereit) return true;
    for (final code in _sprachen) {
      try {
        final verfuegbar = await _tts.isLanguageAvailable(code);
        if (verfuegbar == true || verfuegbar == 1) {
          await _tts.setLanguage(code);
          await _tts.setVolume(1.0);
          await _tts.setPitch(1.0);
          _systemBereit = true;
          return true;
        }
      } catch (_) {
        // nächste Sprachvariante probieren
      }
    }
    return false;
  }

  Future<void> _systemSprich(String satz, {required bool langsam}) async {
    try {
      if (!await _systemVorbereiten()) {
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

  void _vorbereitungZeigen() {
    if (_vorbereitungGezeigt) return;
    _vorbereitungGezeigt = true;
    messengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 6),
          content: Text(
            'Die deutsche Stimme wird vorbereitet.\n'
            'প্রথমবার কয়েক সেকেন্ড লাগবে, তারপর অফলাইনেই কাজ করবে।',
          ),
        ),
      );
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
            'ফোনের Einstellungen → Text-to-speech এ জার্মান ভয়েস ডাউনলোড করো, এবং মিডিয়া ভলিউম বাড়াও।',
          ),
        ),
      );
  }
}
