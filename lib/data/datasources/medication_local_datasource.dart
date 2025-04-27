import 'dart:convert';

import 'package:medialert/core/error/exceptions.dart';
import 'package:medialert/data/models/medication_intake_model.dart';
import 'package:medialert/data/models/medication_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MedicationLocalDataSource {
  Future<List<MedicationModel>> getMedications();
  Future<MedicationModel> getMedicationById(String id);
  Future<void> saveMedication(MedicationModel medication);
  Future<void> deleteMedication(String id);
  Future<void> updateMedication(MedicationModel medication);
  Future<List<MedicationIntakeModel>> getMedicationIntakes();
  Future<void> saveMedicationIntake(MedicationIntakeModel intake);
  Future<void> updateMedicationIntake(MedicationIntakeModel intake);
  Future<List<MedicationIntakeModel>> getFilteredIntakes({
    String? medicationName,
    DateTime? startDate,
    DateTime? endDate,
  });
}

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  final SharedPreferences sharedPreferences;

  MedicationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<MedicationModel>> getMedications() async {
    final jsonString = sharedPreferences.getString('MEDICATIONS_KEY');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((jsonMap) => MedicationModel.fromJson(jsonMap))
          .toList();
    }
    return [];
  }

  @override
  Future<MedicationModel> getMedicationById(String id) async {
    final medications = await getMedications();
    final medication = medications.firstWhere(
      (med) => med.id == id,
      orElse: () => throw CacheException(),
    );
    return medication;
  }

  @override
  Future<void> saveMedication(MedicationModel medication) async {
    final medications = await getMedications();
    medications.add(medication);
    await _saveMedicationsList(medications);
  }

  @override
  Future<void> deleteMedication(String id) async {
    final medications = await getMedications();
    medications.removeWhere((med) => med.id == id);
    await _saveMedicationsList(medications);
  }

  @override
  Future<void> updateMedication(MedicationModel medication) async {
    final medications = await getMedications();
    final index = medications.indexWhere((med) => med.id == medication.id);
    if (index != -1) {
      medications[index] = medication;
      await _saveMedicationsList(medications);
    } else {
      throw CacheException();
    }
  }

  Future<void> _saveMedicationsList(List<MedicationModel> medications) async {
    final jsonList = medications.map((med) => med.toJson()).toList();
    await sharedPreferences.setString('MEDICATIONS_KEY', json.encode(jsonList));
  }

  @override
  Future<List<MedicationIntakeModel>> getMedicationIntakes() async {
    final jsonString = sharedPreferences.getString('MEDICATION_INTAKES_KEY');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((jsonMap) => MedicationIntakeModel.fromJson(jsonMap))
          .toList();
    }
    return [];
  }

  @override
  Future<void> saveMedicationIntake(MedicationIntakeModel intake) async {
    final intakes = await getMedicationIntakes();
    intakes.add(intake);
    await _saveIntakesList(intakes);
  }

  @override
  Future<void> updateMedicationIntake(MedicationIntakeModel intake) async {
    final intakes = await getMedicationIntakes();
    final index = intakes.indexWhere((item) => item.id == intake.id);
    if (index != -1) {
      intakes[index] = intake;
      await _saveIntakesList(intakes);
    } else {
      throw CacheException();
    }
  }

  Future<void> _saveIntakesList(List<MedicationIntakeModel> intakes) async {
    final jsonList = intakes.map((intake) => intake.toJson()).toList();
    await sharedPreferences.setString(
        'MEDICATION_INTAKES_KEY', json.encode(jsonList));
  }

  @override
  Future<List<MedicationIntakeModel>> getFilteredIntakes({
    String? medicationName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final intakes = await getMedicationIntakes();
    return intakes.where((intake) {
      bool matchesName = true;
      bool matchesDateRange = true;

      if (medicationName != null && medicationName.isNotEmpty) {
        matchesName = intake.medicationName
            .toLowerCase()
            .contains(medicationName.toLowerCase());
      }

      if (startDate != null) {
        matchesDateRange = intake.intakeTime.isAfter(startDate) ||
            intake.intakeTime.isAtSameMomentAs(startDate);
      }

      if (endDate != null) {
        final endOfDay =
            DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        matchesDateRange = matchesDateRange &&
            (intake.intakeTime.isBefore(endOfDay) ||
                intake.intakeTime.isAtSameMomentAs(endOfDay));
      }

      return matchesName && matchesDateRange;
    }).toList();
  }
}
