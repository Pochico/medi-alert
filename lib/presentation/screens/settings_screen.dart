import 'package:flutter/material.dart';
import 'package:medialert/presentation/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preferencias de Notificación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Notificaciones Push'),
                        subtitle:
                            const Text('Recibir recordatorios de medicamentos'),
                        value: settingsProvider.pushNotificationsEnabled,
                        onChanged: (value) async {
                          await settingsProvider.togglePushNotifications(value);

                          // Si el usuario intentó activar pero no se concedieron permisos
                          if (value &&
                              !settingsProvider.pushNotificationsEnabled) {
                            if (context.mounted) {
                              _showPermissionDeniedDialog(context);
                            }
                          }
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Alertas por Correo'),
                        subtitle: const Text(
                            'Recibir recordatorios por correo electrónico'),
                        value: settingsProvider.emailAlertsEnabled,
                        onChanged: (value) {
                          settingsProvider.toggleEmailAlerts(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configuración de Sonido',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Sonido de Notificación'),
                        subtitle: const Text(
                            'Reproducir sonido con las notificaciones'),
                        value: settingsProvider.notificationSoundEnabled,
                        onChanged: settingsProvider.pushNotificationsEnabled
                            ? (value) {
                                settingsProvider.toggleNotificationSound(value);
                              }
                            : null,
                      ),
                      ListTile(
                        title: const Text('Volumen'),
                        subtitle: Slider(
                          value: settingsProvider.volume,
                          onChanged:
                              (settingsProvider.pushNotificationsEnabled &&
                                      settingsProvider.notificationSoundEnabled)
                                  ? (value) {
                                      settingsProvider.setVolume(value);
                                    }
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Formato de Hora',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RadioListTile<bool>(
                        title: const Text('12 horas (AM/PM)'),
                        value: false,
                        groupValue: settingsProvider.is24HourFormat,
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.setTimeFormat(value);
                          }
                        },
                      ),
                      RadioListTile<bool>(
                        title: const Text('24 horas'),
                        value: true,
                        groupValue: settingsProvider.is24HourFormat,
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.setTimeFormat(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preferencias de la Aplicación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Modo Oscuro'),
                        subtitle:
                            const Text('Cambiar entre tema claro y oscuro'),
                        value: settingsProvider.isDarkMode,
                        onChanged: (value) {
                          settingsProvider.toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'MediAlert v1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos de Notificación'),
        content: const Text(
          'Para recibir recordatorios de medicamentos, necesitas habilitar los permisos de notificación en la configuración de tu dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Más tarde'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí podrías abrir la configuración del dispositivo
              // Esto varía según la plataforma
            },
            child: const Text('Ir a Configuración'),
          ),
        ],
      ),
    );
  }
}
