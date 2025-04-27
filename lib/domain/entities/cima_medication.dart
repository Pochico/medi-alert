import 'package:equatable/equatable.dart';

class CimaMedication extends Equatable {
  final String name;
  final String registrationNumber;
  final String? activeIngredient;
  final String? laboratory;
  final String? dosage;

  const CimaMedication({
    required this.name,
    required this.registrationNumber,
    this.activeIngredient,
    this.laboratory,
    this.dosage,
  });

  @override
  List<Object?> get props => [
        name,
        registrationNumber,
        activeIngredient,
        laboratory,
        dosage,
      ];
}
