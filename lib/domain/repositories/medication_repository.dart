import 'package:dartz/dartz.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/domain/entities/medication.dart';
import 'package:medialert/domain/entities/medication_intake.dart';

abstract class MedicationRepository {
  Future<Either<Failure, List<Medication>>> getMedications();
  Future<Either<Failure, Medication>> getMedicationById(String id);
  Future<Either<Failure, void>> saveMedication(Medication medication);
  Future<Either<Failure, void>> deleteMedication(String id);
  Future<Either<Failure, void>> updateMedication(Medication medication);
  Future<Either<Failure, List<MedicationIntake>>> getMedicationIntakes();
  Future<Either<Failure, void>> saveMedicationIntake(MedicationIntake intake);
  Future<Either<Failure, void>> updateMedicationIntake(MedicationIntake intake);
  Future<Either<Failure, List<MedicationIntake>>> getFilteredIntakes({
    String? medicationName,
    DateTime? startDate,
    DateTime? endDate,
  });
}
