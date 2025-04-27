import 'package:dartz/dartz.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/domain/entities/cima_medication.dart';

abstract class CimaRepository {
  Future<Either<Failure, List<CimaMedication>>> searchMedications(String query);
  Future<Either<Failure, CimaMedication>> getMedicationDetails(
      String registrationNumber);
}
