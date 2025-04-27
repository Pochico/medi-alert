import 'package:flutter/material.dart';
import 'package:medialert/presentation/screens/add_medication_screen.dart';
import 'package:medialert/presentation/screens/edit_medication_screen.dart';
import 'package:medialert/presentation/screens/history_screen.dart';
import 'package:medialert/presentation/screens/home_screen.dart';
import 'package:medialert/presentation/screens/medication_details_screen.dart';
import 'package:medialert/presentation/screens/settings_screen.dart';

class AppRouter {
  static const String homeRoute = '/';
  static const String addMedicationRoute = '/add-medication';
  static const String editMedicationRoute = '/edit-medication';
  static const String medicationDetailsRoute = '/medication-details';
  static const String historyRoute = '/history';
  static const String settingsRoute = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case addMedicationRoute:
        return MaterialPageRoute(builder: (_) => const AddMedicationScreen());
      case editMedicationRoute:
        final medicationId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditMedicationScreen(medicationId: medicationId),
        );
      case medicationDetailsRoute:
        final medicationId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MedicationDetailsScreen(medicationId: medicationId),
        );
      case historyRoute:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
