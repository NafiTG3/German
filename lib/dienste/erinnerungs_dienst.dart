import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class _Zeitfenster {
  const _Zeitfenster(this.stunde, this.minute, this.titel, this.texte);

  final int stunde;
  final int minute;
  final String titel;
  final List<String> texte;
}

// Tägliche Grüße und Übungserinnerungen auf Deutsch
abstract final class ErinnerungsDienst {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _fenster = <_Zeitfenster>[
    _Zeitfenster(8, 0, 'Guten Morgen!', [
      'Ein neuer Tag, ein neues Wort. Zeit für deine Deutschlektion.',
      'Kaffee, Tee und zehn Minuten Deutsch. Los geht\'s!',
      'Wer früh übt, spricht bald fließend. Deine Lektion wartet.',
    ]),
    _Zeitfenster(13, 0, 'Guten Tag!', [
      'Mittagspause? Wiederhole kurz deine Karten.',
      'Sag heute laut: Ich lerne Deutsch für meine Ausbildung.',
      'Fünf Minuten im Wörterbuch, und schon sitzt ein neues Wort.',
    ]),
    _Zeitfenster(16, 30, 'Guten Nachmittag!', [
      'Zeit für eine kleine Übung. Hör zu und sprich nach.',
      'Hast du heute schon geübt? Ein Quiz dauert nur wenige Minuten.',
      'Lies deinen Dialog noch einmal laut. Das hilft beim Sprechen.',
    ]),
    _Zeitfenster(19, 0, 'Guten Abend!', [
      'Der Abend gehört dem Deutsch. Mach deine Lektion fertig.',
      'Wiederhole die Wörter von heute, dann bleiben sie im Kopf.',
      'Bleib dran: Deine Serie wartet auf dich.',
    ]),
    _Zeitfenster(22, 0, 'Gute Nacht!', [
      'Letzter Blick auf die Karten, dann gut schlafen. Schlaf hilft beim Lernen.',
      'Schlaf gut und träum auf Deutsch. Bis morgen!',
      'Heute geschafft? Dann ruh dich aus. Morgen geht es weiter.',
    ]),
  ];

  static NotificationDetails _details(String text) => NotificationDetails(
        android: AndroidNotificationDetails(
          'taeglich',
          'Tägliche Erinnerung',
          channelDescription: 'Grüße und Übungserinnerungen auf Deutsch',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'notif_klein',
          largeIcon: const DrawableResourceAndroidBitmap('notif_logo'),
          color: const Color(0xFF1E4D33),
          styleInformation: BigTextStyleInformation(text),
        ),
      );

  static Future<void> starten() async {
    try {
      tz.setLocalLocation(tz.UTC);
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('notif_klein'),
        ),
      );
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await _planen();
    } catch (_) {
      // Erinnerungen sind optional, die App läuft auch ohne
    }
  }

  // Jeden Wochentag und jedes Zeitfenster einmal planen, dann wiederholt es sich wöchentlich.
  // Die Zeit wird in UTC umgerechnet, damit keine Zeitzonendatenbank nötig ist.
  static Future<void> _planen() async {
    await _plugin.cancelAll();
    final jetzt = DateTime.now();
    var id = 1000;
    for (var tag = 0; tag < 7; tag++) {
      for (final f in _fenster) {
        var zeit = DateTime(jetzt.year, jetzt.month, jetzt.day + tag, f.stunde, f.minute);
        if (!zeit.isAfter(jetzt)) {
          zeit = DateTime(zeit.year, zeit.month, zeit.day + 7, f.stunde, f.minute);
        }
        final text = f.texte[zeit.weekday % f.texte.length];
        final utc = zeit.toUtc();
        await _plugin.zonedSchedule(
          id++,
          f.titel,
          text,
          tz.TZDateTime.utc(utc.year, utc.month, utc.day, utc.hour, utc.minute),
          _details(text),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }
}
