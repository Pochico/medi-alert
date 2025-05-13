import 'package:flutter/material.dart';
import 'package:medialert/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences sharedPreferences;
  final NotificationService notificationService;

  // Claves para SharedPreferences
  static const String THEME_KEY = 'THEME_MODE';
  static const String PUSH_NOTIFICATIONS_KEY = 'PUSH_NOTIFICATIONS';
  static const String EMAIL_ALERTS_KEY = 'EMAIL_ALERTS';
  static const String NOTIFICATION_SOUND_KEY = 'NOTIFICATION_SOUND';
  static const String VOLUME_KEY = 'VOLUME';
  static const String TIME_FORMAT_KEY = 'TIME_FORMAT';

  // Estados
  bool _isDarkMode = false;
  bool _pushNotificationsEnabled = false;
  bool _emailAlertsEnabled = false;
  bool _notificationSoundEnabled = true;
  double _volume = 0.7;
  bool _is24HourFormat = false;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get emailAlertsEnabled => _emailAlertsEnabled;
  bool get notificationSoundEnabled => _notificationSoundEnabled;
  double get volume => _volume;
  bool get is24HourFormat => _is24HourFormat;

  SettingsProvider({
    required this.sharedPreferences,
    required this.notificationService,
  }) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isDarkMode = sharedPreferences.getBool(THEME_KEY) ?? false;
    _emailAlertsEnabled = sharedPreferences.getBool(EMAIL_ALERTS_KEY) ?? false;
    _notificationSoundEnabled =
        sharedPreferences.getBool(NOTIFICATION_SOUND_KEY) ?? true;
    _volume = sharedPreferences.getDouble(VOLUME_KEY) ?? 0.7;
    _is24HourFormat = sharedPreferences.getBool(TIME_FORMAT_KEY) ?? false;

    // Cargar el estado de los permisos de notificación
    _pushNotificationsEnabled =
        await notificationService.isNotificationPermissionEnabled();

    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    sharedPreferences.setBool(THEME_KEY, _isDarkMode);
    notifyListeners();
  }

  Future<void> togglePushNotifications(bool value) async {
    if (value == _pushNotificationsEnabled) return;

    if (value) {
      // Si se está activando, solicitar permisos
      final permissionGranted =
          await notificationService.requestNotificationPermission();
      _pushNotificationsEnabled = permissionGranted;

      if (!permissionGranted) {
        // Si el usuario denegó los permisos, mostrar un mensaje
        return;
      }
    } else {
      // Si se está desactivando
      _pushNotificationsEnabled = false;
      await notificationService.cancelAllReminders();
    }

    await notificationService
        .setNotificationsEnabled(_pushNotificationsEnabled);
    notifyListeners();
  }

  void toggleEmailAlerts(bool value) {
    _emailAlertsEnabled = value;
    sharedPreferences.setBool(EMAIL_ALERTS_KEY, value);
    notifyListeners();
  }

  void toggleNotificationSound(bool value) {
    _notificationSoundEnabled = value;
    sharedPreferences.setBool(NOTIFICATION_SOUND_KEY, value);
    notifyListeners();
  }

  void setVolume(double value) {
    _volume = value;
    sharedPreferences.setDouble(VOLUME_KEY, value);
    notifyListeners();
  }

  void setTimeFormat(bool is24Hour) {
    _is24HourFormat = is24Hour;
    sharedPreferences.setBool(TIME_FORMAT_KEY, is24Hour);
    notifyListeners();
  }
}
