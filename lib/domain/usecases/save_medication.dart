import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/core/usecases/usecase.dart';
import 'package:medialert/domain/entities/medication.dart';
import 'package:medialert/domain/repositories/medication_repository.dart';

class SaveMedication implements UseCase<void, SaveMedicationParams> {
  final MedicationRepository repository;

  SaveMedication(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveMedicationParams params) async {
    return await repository.saveMedication(params.medication);
  }
}

class SaveMedicationParams extends Equatable {
  final Medication medication;

  const SaveMedicationParams({required this.medication});

  @override
  List<Object> get props => [medication];
}
