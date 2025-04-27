import 'package:equatable/equatable.dart';

class Medication extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final List<DateTime> reminders;
  final String? notes;
  final bool isActive;
  final String? registrationNumber; // Número de registro CIMA

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.reminders,
    this.notes,
    this.isActive = true,
    this.registrationNumber,
  });

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    List<DateTime>? reminders,
    String? notes,
    bool? isActive,
    String? registrationNumber,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      reminders: reminders ?? this.reminders,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      registrationNumber: registrationNumber ?? this.registrationNumber,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        dosage,
        frequency,
        reminders,
        notes,
        isActive,
        registrationNumber,
      ];
}
