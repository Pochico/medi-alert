import 'dart:convert';
import 'dart:io';

// Importar para manejar permisos de alarma exacta
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medialert/domain/entities/medication.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_init;
import 'package:timezone/timezone.dart' as tz;

class ReceivedNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification({
    required this.id,
    this.title,
    this.body,
    this.payload,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<ReceivedNotification> onNotificationClick =
      BehaviorSubject<ReceivedNotification>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Clave para guardar el token FCM en SharedPreferences
  static const String FCM_TOKEN_KEY = 'FCM_TOKEN';

  // Clave para guardar el estado de permisos de notificaciones
  static const String NOTIFICATION_PERMISSION_KEY = 'NOTIFICATION_PERMISSION';

  // Clave para guardar el estado de permisos de alarmas exactas
  static const String EXACT_ALARM_PERMISSION_KEY = 'EXACT_ALARM_PERMISSION';

  NotificationService._internal();

  Future<void> init() async {
    tz_init.initializeTimeZones();

    // Configuración para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    Map<String, dynamic> parsePayload(String payload) {
      try {
        return Map<String, dynamic>.from(jsonDecode(payload));
      } catch (e) {
        print('Error parsing payload: $e');
        return {};
      }
    }

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Parse the payload to extract the necessary data
        final payload = response.payload;
        if (payload != null) {
          // Assuming the payload is a JSON string containing id, title, and body
          final data = parsePayload(payload);

          onNotificationClick.add(ReceivedNotification(
            id: data['id'] ?? 0,
            title: data['title'],
            body: data['body'],
            payload: payload,
          ));
        }
      },
    );

    // Inicializar AlarmManager para Android
    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }

    // Configurar canales de notificación para Android
    await _setupNotificationChannels();

    // Configurar Firebase Messaging
    await _setupFirebaseMessaging();
  }

  Future<void> _setupNotificationChannels() async {
    // Canal para recordatorios de medicamentos
    const AndroidNotificationChannel medicationRemindersChannel =
        AndroidNotificationChannel(
      'medication_reminders',
      'Recordatorios de Medicamentos',
      description: 'Notificaciones para recordarte tomar tus medicamentos',
      importance: Importance.high,
      enableVibration: true,
    );

    // Canal para actualizaciones generales
    const AndroidNotificationChannel generalUpdatesChannel =
        AndroidNotificationChannel(
      'general_updates',
      'Actualizaciones Generales',
      description: 'Notificaciones generales de la aplicación',
      importance: Importance.defaultImportance,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(medicationRemindersChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalUpdatesChannel);
  }

  Future<void> _setupFirebaseMessaging() async {
    // Solicitar permiso para iOS
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Manejar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleRemoteMessage(message);
    });

    // Manejar mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Manejar cuando se abre la app desde una notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationOpen(message);
    });

    // Verificar si la app se abrió desde una notificación
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage);
    }

    // Obtener y guardar el token FCM
    await _updateFcmToken();
  }

  Future<void> _updateFcmToken() async {
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(FCM_TOKEN_KEY, token);

      // Aquí podrías enviar el token a tu servidor para enviar notificaciones personalizadas
      print('FCM Token: $token');
    }

    // Escuchar cambios en el token
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(FCM_TOKEN_KEY, newToken);

      // Actualizar el token en tu servidor
      print('FCM Token actualizado: $newToken');
    });
  }

  void _handleRemoteMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Recordatorios de Medicamentos',
            icon: android.smallIcon,
          ),
        ),
        payload: message.data['medicationId'],
      );
    }
  }

  void _handleNotificationOpen(RemoteMessage message) {
    // Aquí puedes manejar la navegación cuando se abre una notificación
    // Por ejemplo, navegar a la pantalla de detalles del medicamento
    if (message.data.containsKey('medicationId')) {
      // Implementar navegación a la pantalla de detalles
      print('Abrir detalles del medicamento: ${message.data['medicationId']}');
    }
  }

  // Método para verificar si los permisos de alarma exacta están habilitados (Android 12+)
  Future<bool> _checkExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // Verificar si estamos en Android 12 o superior
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Si es Android 12+ (API 31+), verificar el permiso
      if (sdkInt >= 31) {
        // Usar permission_handler para verificar el permiso
        final status = await Permission.scheduleExactAlarm.status;
        return status.isGranted;
      }

      // En versiones anteriores, el permiso en el manifest es suficiente
      return true;
    } catch (e) {
      print('Error al verificar permiso de alarma exacta: $e');
      return false;
    }
  }

  // Método para solicitar permiso de alarma exacta (Android 12+)
  Future<bool> _requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // Verificar si estamos en Android 12 o superior
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Si es Android 12+ (API 31+), solicitar el permiso
      if (sdkInt >= 31) {
        // Usar permission_handler para solicitar el permiso
        final status = await Permission.scheduleExactAlarm.request();

        // Guardar el estado del permiso
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(EXACT_ALARM_PERMISSION_KEY, status.isGranted);

        return status.isGranted;
      }

      // En versiones anteriores, el permiso en el manifest es suficiente
      return true;
    } catch (e) {
      print('Error al solicitar permiso de alarma exacta: $e');
      return false;
    }
  }

  // Método para programar recordatorios de medicamentos
  Future<void> scheduleMedicationReminder(
      Medication medication, DateTime reminderTime) async {
    final isPermissionEnabled = await isNotificationPermissionEnabled();
    if (!isPermissionEnabled) return;

    // Verificar y solicitar permiso de alarma exacta si es necesario
    bool hasExactAlarmPermission = await _checkExactAlarmPermission();
    if (!hasExactAlarmPermission) {
      hasExactAlarmPermission = await _requestExactAlarmPermission();
      if (!hasExactAlarmPermission) {
        print('No se pudo obtener permiso para alarmas exactas');
        // Intentar usar alarmas inexactas como alternativa
        return _scheduleInexactMedicationReminder(medication, reminderTime);
      }
    }

    final id = medication.id.hashCode;

    final androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Recordatorios de Medicamentos',
      channelDescription:
          'Notificaciones para recordarte tomar tus medicamentos',
      importance: Importance.high,
      priority: Priority.high,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    final iOSDetails = DarwinNotificationDetails(
      sound: 'notification_sound.aiff',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      // Programar la notificación
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Recordatorio de medicamento',
        'Es hora de tomar ${medication.name} - ${medication.dosage}',
        tz.TZDateTime.from(reminderTime, tz.local),
        platformDetails,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: medication.id,
        androidScheduleMode: AndroidScheduleMode.exact,
      );
      print(
          'Notificación programada con éxito para ${medication.name} a las ${reminderTime.hour}:${reminderTime.minute}');
    } catch (e) {
      print('Error al programar notificación exacta: $e');
      // Si falla, intentar con alarma inexacta
      await _scheduleInexactMedicationReminder(medication, reminderTime);
    }
  }

  // Método alternativo para programar recordatorios inexactos
  Future<void> _scheduleInexactMedicationReminder(
      Medication medication, DateTime reminderTime) async {
    final id = medication.id.hashCode;

    final androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Recordatorios de Medicamentos',
      channelDescription:
          'Notificaciones para recordarte tomar tus medicamentos',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      // Programar notificación inexacta
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Recordatorio de medicamento',
        'Es hora de tomar ${medication.name} - ${medication.dosage}',
        tz.TZDateTime.from(reminderTime, tz.local),
        platformDetails,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: medication.id,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      print('Notificación inexacta programada para ${medication.name}');
    } catch (e) {
      print('Error al programar notificación inexacta: $e');
    }
  }

  // Método para cancelar un recordatorio específico
  Future<void> cancelMedicationReminder(String medicationId) async {
    await flutterLocalNotificationsPlugin.cancel(medicationId.hashCode);
  }

  // Método para cancelar todos los recordatorios
  Future<void> cancelAllReminders() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Método para verificar si los permisos de notificación están habilitados
  Future<bool> isNotificationPermissionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(NOTIFICATION_PERMISSION_KEY) ?? false;
  }

  // Método para solicitar permisos de notificación
  Future<bool> requestNotificationPermission() async {
    bool permissionGranted = false;

    if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized;
    } else {
      // En Android, verificamos si el canal está habilitado
      final androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        permissionGranted =
            await androidImplementation.areNotificationsEnabled() ?? false;

        if (!permissionGranted) {
          // En Android 13+, necesitamos solicitar permisos explícitamente
          permissionGranted =
              await androidImplementation.requestNotificationsPermission() ??
                  false;
        }
      }
    }

    // Guardar el estado del permiso
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(NOTIFICATION_PERMISSION_KEY, permissionGranted);

    // Si se concedió el permiso de notificación, también solicitar permiso de alarma exacta
    if (permissionGranted && Platform.isAndroid) {
      await _requestExactAlarmPermission();
    }

    return permissionGranted;
  }

  // Método para habilitar/deshabilitar notificaciones
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    if (enabled) {
      // Si se están habilitando, solicitar permisos
      final permissionGranted = await requestNotificationPermission();
      await prefs.setBool(NOTIFICATION_PERMISSION_KEY, permissionGranted);
    } else {
      // Si se están deshabilitando, guardar la preferencia
      await prefs.setBool(NOTIFICATION_PERMISSION_KEY, false);
      // Cancelar todas las notificaciones programadas
      await cancelAllReminders();
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Necesitamos inicializar Firebase aquí si queremos usar Firebase en segundo plano
  // await Firebase.initializeApp();

  print(
      "Notificación recibida en segundo plano: ${message.notification?.title}");
}
