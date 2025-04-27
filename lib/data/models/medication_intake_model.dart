import 'package:medialert/domain/entities/medication_intake.dart';

class MedicationIntakeModel extends MedicationIntake {
  const MedicationIntakeModel({
    required String id,
    required String medicationId,
    required String medicationName,
    required String dosage,
    required DateTime intakeTime,
    bool taken = false,
  }) : super(
          id: id,
          medicationId: medicationId,
          medicationName: medicationName,
          dosage: dosage,
          intakeTime: intakeTime,
          taken: taken,
        );

  factory MedicationIntakeModel.fromJson(Map<String, dynamic> json) {
    return MedicationIntakeModel(
      id: json['id'],
      medicationId: json['medicationId'],
      medicationName: json['medicationName'],
      dosage: json['dosage'],
      intakeTime: DateTime.parse(json['intakeTime']),
      taken: json['taken'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'intakeTime': intakeTime.toIso8601String(),
      'taken': taken,
    };
  }

  factory MedicationIntakeModel.fromEntity(MedicationIntake intake) {
    return MedicationIntakeModel(
      id: intake.id,
      medicationId: intake.medicationId,
      medicationName: intake.medicationName,
      dosage: intake.dosage,
      intakeTime: intake.intakeTime,
      taken: intake.taken,
    );
  }
}
