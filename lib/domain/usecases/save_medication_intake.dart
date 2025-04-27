import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/core/usecases/usecase.dart';
import 'package:medialert/domain/entities/medication_intake.dart';
import 'package:medialert/domain/repositories/medication_repository.dart';

class SaveMedicationIntake implements UseCase<void, SaveIntakeParams> {
  final MedicationRepository repository;

  SaveMedicationIntake(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveIntakeParams params) async {
    return await repository.saveMedicationIntake(params.intake);
  }
}

class SaveIntakeParams extends Equatable {
  final MedicationIntake intake;

  const SaveIntakeParams({required this.intake});

  @override
  List<Object> get props => [intake];
}
