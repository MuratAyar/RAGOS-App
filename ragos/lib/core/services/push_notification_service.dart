// lib/core/services/push_notification_service.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../../models/analysis_notification.dart';
import '../../screens/notification_detail_screen.dart';

/// FCM + local-notification entegrasyonu
class PushNotificationService {
  // ───────────────────────────── navigator
  static final navigatorKey = GlobalKey<NavigatorState>();

  // ───────────────────────────── FCM & LocalNotif
  static final _fcm   = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();

  // Yüksek öncelikli (heads-up) Android kanalı
  static const _androidChannel = AndroidNotificationChannel(
    'care_alerts',                       // id
    'Care Interaction Alerts',           // görünen ad
    description : 'Urgent care-safety notifications',
    importance  : Importance.high,
    playSound   : true,
    enableVibration: true,
  );

  /// Uygulama açılır açılmaz **bir kez** çağır
  static Future<void> init() async {
    // 1) iOS izinleri
    await _fcm.requestPermission();

    // 2) Android kanalını oluştur
    final androidPlugin = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    // 3) Token Firestore’a
    await _saveTokenToDb();

    // 4) Foreground initialisation
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS    : DarwinInitializationSettings(),
    );
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) => _openDetail(resp.payload),
    );

    // 5) Dinleyiciler
    FirebaseMessaging.onMessage.listen(_showForeground);
    FirebaseMessaging.onMessageOpenedApp
        .listen((m) => _openDetail(m.data['notifId']));
    FirebaseMessaging.onBackgroundMessage(_bgHandler);
  }

  // ────────────────────────────────────────────────────────────────────────
  static Future<void> _saveTokenToDb() async {
    final uid   = FirebaseAuth.instance.currentUser?.uid;
    final token = await _fcm.getToken();
    if (uid == null || token == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('device_tokens')
        .doc(token);

    await ref.set({
      'platform': Platform.operatingSystem,
      'at'      : FieldValue.serverTimestamp(),
    });

    // Token yenilenirse
    _fcm.onTokenRefresh.listen((t) => ref.set({
          'platform': Platform.operatingSystem,
          'at'      : FieldValue.serverTimestamp(),
        }));
  }

  // ────────────────────────────────────────────────────────────────────────
  /// Uygulama **ön plandayken** bildirimi yerel olarak göster
  static final AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'care_alerts',                       // id
    'Care Interaction Alerts',           // görünen ad
    description:
        'Urgent care-safety notifications',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> _showForeground(RemoteMessage m) async {
    final n = m.notification;
    await _local.show(
      0,
      n?.title ?? 'Care Interaction Alert',
      n?.body  ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'care_alerts',                    // id - string
          'Care Interaction Alerts',        // ad - string
          channelDescription: 'Urgent care-safety notifications',
          importance: Importance.high,
          priority : Priority.high,
          playSound: true,
          styleInformation: const BigTextStyleInformation(''),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      payload: m.data['notifId'],
    );
  }

  /// **Background handler** (Android) – içerik gerekmediği için boş
  static Future<void> _bgHandler(RemoteMessage m) async {}

  // ────────────────────────────────────────────────────────────────────────
  /// Bildirime tıklanınca detay sayfasını aç
  static Future<void> _openDetail(String? notifId) async {
    if (notifId == null) return;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Firestore'dan bildirimi getir
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications') // koleksiyon adınız buysa
          .doc(notifId)
          .get();

      if (!snap.exists) return;

      final notif = AnalysisNotification.fromDoc(snap.id, snap.data()!);

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => NotificationDetailScreen(notification: notif),
        ),
      );
    } catch (_) {
      // Sessiz yut – navigasyonu engellemesin
    }
  }
}
