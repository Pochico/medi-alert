import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/core/usecases/usecase.dart';
import 'package:medialert/domain/entities/medication.dart';
import 'package:medialert/domain/repositories/medication_repository.dart';

class GetMedicationById implements UseCase<Medication, MedicationParams> {
  final MedicationRepository repository;

  GetMedicationById(this.repository);

  @override
  Future<Either<Failure, Medication>> call(MedicationParams params) async {
    return await repository.getMedicationById(params.id);
  }
}

class MedicationParams extends Equatable {
  final String id;

  const MedicationParams({required this.id});

  @override
  List<Object> get props => [id];
}
