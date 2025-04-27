import 'package:dartz/dartz.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/core/usecases/usecase.dart';
import 'package:medialert/domain/entities/medication.dart';
import 'package:medialert/domain/repositories/medication_repository.dart';

class GetMedications implements UseCase<List<Medication>, NoParams> {
  final MedicationRepository repository;

  GetMedications(this.repository);

  @override
  Future<Either<Failure, List<Medication>>> call(NoParams params) async {
    return await repository.getMedications();
  }
}
