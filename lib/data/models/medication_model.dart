import 'package:medialert/domain/entities/medication.dart';

class MedicationModel extends Medication {
  const MedicationModel({
    required String id,
    required String name,
    required String dosage,
    required String frequency,
    required List<DateTime> reminders,
    String? notes,
    bool isActive = true,
    String? registrationNumber,
  }) : super(
          id: id,
          name: name,
          dosage: dosage,
          frequency: frequency,
          reminders: reminders,
          notes: notes,
          isActive: isActive,
          registrationNumber: registrationNumber,
        );

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      reminders: (json['reminders'] as List)
          .map((time) => DateTime.parse(time))
          .toList(),
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      registrationNumber: json['registrationNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'reminders': reminders.map((time) => time.toIso8601String()).toList(),
      'notes': notes,
      'isActive': isActive,
      'registrationNumber': registrationNumber,
    };
  }

  factory MedicationModel.fromEntity(Medication medication) {
    return MedicationModel(
      id: medication.id,
      name: medication.name,
      dosage: medication.dosage,
      frequency: medication.frequency,
      reminders: medication.reminders,
      notes: medication.notes,
      isActive: medication.isActive,
      registrationNumber: medication.registrationNumber,
    );
  }
}
