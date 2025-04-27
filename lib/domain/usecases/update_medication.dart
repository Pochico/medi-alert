import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/core/usecases/usecase.dart';
import 'package:medialert/domain/entities/medication.dart';
import 'package:medialert/domain/repositories/medication_repository.dart';

class UpdateMedication implements UseCase<void, UpdateMedicationParams> {
  final MedicationRepository repository;

  UpdateMedication(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateMedicationParams params) async {
    return await repository.updateMedication(params.medication);
  }
}

class UpdateMedicationParams extends Equatable {
  final Medication medication;

  const UpdateMedicationParams({required this.medication});

  @override
  List<Object> get props => [medication];
}
