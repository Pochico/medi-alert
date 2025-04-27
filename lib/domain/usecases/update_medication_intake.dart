import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/core/usecases/usecase.dart';
import 'package:medialert/domain/entities/medication_intake.dart';
import 'package:medialert/domain/repositories/medication_repository.dart';

class UpdateMedicationIntake implements UseCase<void, UpdateIntakeParams> {
  final MedicationRepository repository;

  UpdateMedicationIntake(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateIntakeParams params) async {
    return await repository.updateMedicationIntake(params.intake);
  }
}

class UpdateIntakeParams extends Equatable {
  final MedicationIntake intake;

  const UpdateIntakeParams({required this.intake});

  @override
  List<Object> get props => [intake];
}
