import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  String? _fcmToken;
  bool _notificationsEnabled = false;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    try {

      await _initializeLocalNotifications();

      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Permessi notifiche concessi');
        _notificationsEnabled = true;
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('⚠️ Permessi notifiche provvisori');
        _notificationsEnabled = true;
      } else {
        debugPrint('❌ Permessi notifiche negati');
        _notificationsEnabled = false;
      }

      _fcmToken = await _messaging.getToken();
      debugPrint('📱 Token FCM: $_fcmToken');

      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔄 Token FCM aggiornato: $newToken');
      });

      // Listener per messaggi in foreground (app aperta)
      // Nota: questo listener rimane attivo per tutta la vita dell'app
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🎯 [FCM FOREGROUND] Messaggio ricevuto in tempo reale');
        debugPrint('   Titolo: ${message.notification?.title}');
        debugPrint('   Corpo: ${message.notification?.body}');
        debugPrint('   Dati: ${message.data}');
        _handleForegroundMessage(message);
      }, onError: (error) {
        debugPrint('❌ [FCM FOREGROUND] Errore listener: $error');
      });

      // Listener per messaggi quando l'app viene aperta da una notifica
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick, onError: (error) {
        debugPrint('❌ [FCM OPENED] Errore listener: $error');
      });

      RemoteMessage? initialMessage =
          await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage);
      }
      
      debugPrint('✅ [FCM] Listener configurati correttamente');
    } catch (e) {
      debugPrint('❌ Errore inizializzazione notifiche: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('👆 Notifica locale cliccata: ${response.payload}');
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'roadguardian_alerts',
      'Avvisi Incidenti',
      description: 'Notifiche per incidenti nelle vicinanze',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Apri la pagina delle impostazioni di sistema per le notifiche dell'app.
  Future<void> openNotificationSettings() async {
    try {
      const platform = MethodChannel('roadguardian.app/settings');
      await platform.invokeMethod('openNotificationSettings');
      debugPrint('Aperte impostazioni notifiche');
    } catch (e) {
      debugPrint('Errore apertura impostazioni: $e');
      rethrow;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 [_handleForegroundMessage] Elaborazione notifica ricevuta in foreground');
    debugPrint('   Titolo: ${message.notification?.title}');
    debugPrint('   Corpo: ${message.notification?.body}');
    debugPrint('   Dati: ${message.data}');

    if (message.notification != null) {
      debugPrint('   ✅ Notifica ha titolo/corpo, mostro notifica locale');
      _showLocalNotification(
        message.notification!.title ?? 'Notifica',
        message.notification!.body ?? '',
        message.data['incident_id'],
      );
    } else {
      debugPrint('   ⚠️ Notifica senza titolo/corpo, ignoro');
    }
  }

  Future<void> _showLocalNotification(
    String title,
    String body,
    String? incidentId,
  ) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'roadguardian_alerts',
      'Avvisi Incidenti',
      channelDescription: 'Notifiche per incidenti nelle vicinanze',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF0000),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // Usa ID univoco incrementale per evitare sovrascritture
    final now = DateTime.now();
    final notificationId = now.millisecondsSinceEpoch % 100000;

    await _localNotifications.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: incidentId,
    );

    debugPrint('🔔 Notifica locale mostrata nel notification tray (ID: $notificationId)');
  }

  /// Mostra una notifica locale pubblica (helper per test/debug).
  /// Nota: le notifiche locali possono essere mostrate anche senza permessi FCM.
  Future<void> showTestNotification(String title, String body, [String? incidentId]) async {
    try {
      await _showLocalNotification(title, body, incidentId);
    } catch (e) {
      debugPrint('❌ Errore mostra notifica test: $e');
      rethrow;
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    debugPrint('👆 Notifica cliccata');
    debugPrint('Dati: ${message.data}');

    final String? incidentId = message.data['incident_id'];
    if (incidentId != null) {
      debugPrint('🚨 Apri dettagli incidente: $incidentId');

    }
  }

  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      debugPrint('🗑️ Token FCM eliminato');
    } catch (e) {
      debugPrint('❌ Errore eliminazione token: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 Notifica ricevuta in background');
  debugPrint('Titolo: ${message.notification?.title}');
  debugPrint('Corpo: ${message.notification?.body}');
}
