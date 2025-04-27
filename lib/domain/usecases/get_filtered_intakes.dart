import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/core/usecases/usecase.dart';
import 'package:medialert/domain/entities/medication_intake.dart';
import 'package:medialert/domain/repositories/medication_repository.dart';

class GetFilteredIntakes
    implements UseCase<List<MedicationIntake>, FilterParams> {
  final MedicationRepository repository;

  GetFilteredIntakes(this.repository);

  @override
  Future<Either<Failure, List<MedicationIntake>>> call(
      FilterParams params) async {
    return await repository.getFilteredIntakes(
      medicationName: params.medicationName,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class FilterParams extends Equatable {
  final String? medicationName;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterParams({
    this.medicationName,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [medicationName, startDate, endDate];
}
