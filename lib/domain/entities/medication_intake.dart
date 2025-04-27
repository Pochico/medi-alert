import 'package:equatable/equatable.dart';

class MedicationIntake extends Equatable {
  final String id;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final DateTime intakeTime;
  final bool taken;

  const MedicationIntake({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.intakeTime,
    this.taken = false,
  });

  MedicationIntake copyWith({
    String? id,
    String? medicationId,
    String? medicationName,
    String? dosage,
    DateTime? intakeTime,
    bool? taken,
  }) {
    return MedicationIntake(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      intakeTime: intakeTime ?? this.intakeTime,
      taken: taken ?? this.taken,
    );
  }

  @override
  List<Object?> get props => [
        id,
        medicationId,
        medicationName,
        dosage,
        intakeTime,
        taken,
      ];
}
