import 'package:medialert/domain/entities/cima_medication.dart';

class CimaMedicationModel extends CimaMedication {
  const CimaMedicationModel({
    required String name,
    required String registrationNumber,
    String? activeIngredient,
    String? laboratory,
    String? dosage,
  }) : super(
          name: name,
          registrationNumber: registrationNumber,
          activeIngredient: activeIngredient,
          laboratory: laboratory,
          dosage: dosage,
        );

  factory CimaMedicationModel.fromJson(Map<String, dynamic> json) {
    return CimaMedicationModel(
      name: json['nombre'] ?? '',
      registrationNumber: json['nregistro'] ?? '',
      activeIngredient: json['pactivos'],
      laboratory: json['labtitular'],
      dosage: json['dosis'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': name,
      'nregistro': registrationNumber,
      'pactivos': activeIngredient,
      'labtitular': laboratory,
      'dosis': dosage,
    };
  }
}
