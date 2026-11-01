import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as mathe;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

// Eingebaute deutsche Stimme (Piper, Thorsten, männlich), läuft komplett offline.
// Modell und Daten liegen als Assets in der App und werden beim ersten Start entpackt.
class StimmeMotor {
  StimmeMotor._();

  static final instanz = StimmeMotor._();

  static const _ordnerName = 'stimme_thorsten_v1';
  static const _langsamTempo = 0.7;
  static const _normalTempo = 0.95;

  Future<bool>? _start;
  bool? _fertig;
  SendPort? _arbeiter;
  Directory? _cache;

  // null: wird noch vorbereitet, true: bereit, false: nicht verfügbar
  bool? get fertig => _fertig;

  Future<bool> bereit() => _start ??= _initialisieren();

  Future<bool> _initialisieren() async {
    try {
      final support = await getApplicationSupportDirectory();
      final ordner = Directory('${support.path}/$_ordnerName');
      final marker = File('${ordner.path}/fertig');
      if (!await marker.exists()) {
        if (await ordner.exists()) await ordner.delete(recursive: true);
        await ordner.create(recursive: true);
        await _assetSchreiben('assets/stimme/model.onnx', '${ordner.path}/model.onnx');
        await _assetSchreiben('assets/stimme/tokens.txt', '${ordner.path}/tokens.txt');
        final zip = await rootBundle.load('assets/stimme/espeak.zip');
        await compute(
          _entpacken,
          <Object>[
            zip.buffer.asUint8List(zip.offsetInBytes, zip.lengthInBytes),
            ordner.path,
          ],
        );
        await marker.writeAsString('ok');
      }

      final temp = await getTemporaryDirectory();
      _cache = await Directory('${temp.path}/stimme_cache').create(recursive: true);

      final empfang = ReceivePort();
      await Isolate.spawn(_arbeiterStart, <Object>[
        empfang.sendPort,
        '${ordner.path}/model.onnx',
        '${ordner.path}/tokens.txt',
        '${ordner.path}/espeak-ng-data',
      ]);
      final erste = await empfang.first.timeout(const Duration(seconds: 90));
      empfang.close();
      if (erste is SendPort) {
        _arbeiter = erste;
        _fertig = true;
        return true;
      }
    } catch (_) {
      // Ohne Modell (z. B. lokaler Build) übernimmt die Stimme des Telefons
    }
    _fertig = false;
    return false;
  }

  Future<void> _assetSchreiben(String asset, String ziel) async {
    final daten = await rootBundle.load(asset);
    await File(ziel).writeAsBytes(
      daten.buffer.asUint8List(daten.offsetInBytes, daten.lengthInBytes),
      flush: true,
    );
  }

  // Liefert den Pfad einer WAV Datei, oder null bei einem Fehler
  Future<String?> erzeuge(String text, {required bool langsam}) async {
    final arbeiter = _arbeiter;
    final cache = _cache;
    if (arbeiter == null || cache == null) return null;
    final ziel = '${cache.path}/${_hash(text)}_${langsam ? 'l' : 'n'}.wav';
    if (await File(ziel).exists()) return ziel;

    final antwort = ReceivePort();
    arbeiter.send(<Object>[
      text,
      langsam ? _langsamTempo : _normalTempo,
      ziel,
      antwort.sendPort,
    ]);
    final ok = await antwort.first.timeout(
      const Duration(seconds: 30),
      onTimeout: () => false,
    );
    antwort.close();
    return ok == true ? ziel : null;
  }

  // FNV-1a, damit gleiche Texte denselben Dateinamen bekommen
  static String _hash(String s) {
    var h = 0x811c9dc5;
    for (final b in utf8.encode(s)) {
      h ^= b;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h.toRadixString(16);
  }
}

void _entpacken(List<Object> args) {
  final bytes = args[0] as Uint8List;
  final ziel = args[1] as String;
  final archiv = ZipDecoder().decodeBytes(bytes);
  for (final datei in archiv) {
    final pfad = '$ziel/${datei.name}';
    if (datei.isFile) {
      File(pfad)
        ..createSync(recursive: true)
        ..writeAsBytesSync(datei.content as List<int>);
    } else {
      Directory(pfad).createSync(recursive: true);
    }
  }
}

sherpa.OfflineTts? _baueMotor(List<Object> args) {
  try {
    sherpa.initBindings();
    final vits = sherpa.OfflineTtsVitsModelConfig(
      model: args[1] as String,
      tokens: args[2] as String,
      dataDir: args[3] as String,
    );
    final modell = sherpa.OfflineTtsModelConfig(
      vits: vits,
      numThreads: 2,
      debug: false,
    );
    return sherpa.OfflineTts(sherpa.OfflineTtsConfig(model: modell));
  } catch (_) {
    return null;
  }
}

// Eigener Isolate, damit die Sprachsynthese die Oberfläche nicht ruckeln lässt
void _arbeiterStart(List<Object> args) {
  final ausgang = args[0] as SendPort;
  final motor = _baueMotor(args);
  if (motor == null) {
    ausgang.send('fehler');
    return;
  }
  final anfragen = ReceivePort();
  ausgang.send(anfragen.sendPort);
  anfragen.listen((nachricht) {
    final liste = nachricht as List<Object>;
    final antwort = liste[3] as SendPort;
    try {
      final audio = motor.generate(
        text: liste[0] as String,
        sid: 0,
        speed: liste[1] as double,
      );
      final ziel = liste[2] as String;
      File('$ziel.tmp').writeAsBytesSync(_wavBytes(audio.samples, audio.sampleRate));
      File('$ziel.tmp').renameSync(ziel);
      antwort.send(true);
    } catch (_) {
      antwort.send(false);
    }
  });
}

// 16 Bit Mono WAV, mit kurzer Stille am Anfang, damit der Player nichts abschneidet
Uint8List _wavBytes(Float32List samples, int rate) {
  final stille = (rate * 0.08).round();
  final gesamt = stille + samples.length;
  final daten = ByteData(44 + gesamt * 2);
  void schreibe(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      daten.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  schreibe(0, 'RIFF');
  daten.setUint32(4, 36 + gesamt * 2, Endian.little);
  schreibe(8, 'WAVE');
  schreibe(12, 'fmt ');
  daten.setUint32(16, 16, Endian.little);
  daten.setUint16(20, 1, Endian.little);
  daten.setUint16(22, 1, Endian.little);
  daten.setUint32(24, rate, Endian.little);
  daten.setUint32(28, rate * 2, Endian.little);
  daten.setUint16(32, 2, Endian.little);
  daten.setUint16(34, 16, Endian.little);
  schreibe(36, 'data');
  daten.setUint32(40, gesamt * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    final wert = mathe.max(-1.0, mathe.min(1.0, samples[i]));
    daten.setInt16(44 + (stille + i) * 2, (wert * 32767).round(), Endian.little);
  }
  return daten.buffer.asUint8List();
}
