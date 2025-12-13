import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servizio per gestire le notifiche push con Firebase Cloud Messaging
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  String? _fcmToken;

  /// Ottieni il token FCM corrente
  String? get fcmToken => _fcmToken;

  /// Inizializza Firebase Messaging e richiedi i permessi
  Future<void> initialize() async {
    try {
      // Inizializza local notifications
      await _initializeLocalNotifications();

      // Richiedi permessi per le notifiche (iOS e Android 13+)
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
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('⚠️ Permessi notifiche provvisori');
      } else {
        debugPrint('❌ Permessi notifiche negati');
      }

      // Ottieni il token FCM
      _fcmToken = await _messaging.getToken();
      debugPrint('📱 Token FCM: $_fcmToken');

      // Listener per refresh del token
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔄 Token FCM aggiornato: $newToken');
      });

      // Gestione notifiche in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Gestione notifiche quando l'app viene aperta da una notifica
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

      // Controlla se l'app è stata aperta da una notifica mentre era terminata
      RemoteMessage? initialMessage =
          await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage);
      }
    } catch (e) {
      debugPrint('❌ Errore inizializzazione notifiche: $e');
    }
  }

  /// Inizializza le notifiche locali
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

    // Crea canale di notifica per Android
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

  /// Gestisce le notifiche ricevute quando l'app è in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 Notifica ricevuta in foreground');
    debugPrint('Titolo: ${message.notification?.title}');
    debugPrint('Corpo: ${message.notification?.body}');
    debugPrint('Dati: ${message.data}');

    // Mostra notifica locale nel notification tray
    if (message.notification != null) {
      _showLocalNotification(
        message.notification!.title ?? 'Notifica',
        message.notification!.body ?? '',
        message.data['incident_id'],
      );
    }
  }

  /// Mostra una notifica locale nel notification tray
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
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF0000),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      0, // ID notifica
      title,
      body,
      notificationDetails,
      payload: incidentId,
    );

    debugPrint('🔔 Notifica locale mostrata nel notification tray');
  }

  /// Gestisce il click su una notifica
  void _handleNotificationClick(RemoteMessage message) {
    debugPrint('👆 Notifica cliccata');
    debugPrint('Dati: ${message.data}');

    // Qui puoi navigare a una schermata specifica
    // Per esempio, se c'è un incident_id nei dati, apri i dettagli
    final String? incidentId = message.data['incident_id'];
    if (incidentId != null) {
      debugPrint('🚨 Apri dettagli incidente: $incidentId');
      // TODO: Navigare alla pagina dettaglio segnalazione
    }
  }

  /// Cancella il token FCM (utile per logout)
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

/// Handler per notifiche in background (deve essere top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 Notifica ricevuta in background');
  debugPrint('Titolo: ${message.notification?.title}');
  debugPrint('Corpo: ${message.notification?.body}');
}
