import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medialert/presentation/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class TimeFormatUtil {
  static String formatTime(BuildContext context, DateTime dateTime) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    if (settingsProvider.is24HourFormat) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat('hh:mm a').format(dateTime);
    }
  }

  static String formatDateTime(BuildContext context, DateTime dateTime) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = settingsProvider.is24HourFormat
        ? DateFormat('HH:mm')
        : DateFormat('hh:mm a');

    return '${dateFormat.format(dateTime)} ${timeFormat.format(dateTime)}';
  }
}
