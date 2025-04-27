import 'package:dartz/dartz.dart';
import 'package:medialert/core/error/exceptions.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/core/network/network_info.dart';
import 'package:medialert/data/datasources/medication_local_datasource.dart';
import 'package:medialert/data/models/medication_intake_model.dart';
import 'package:medialert/data/models/medication_model.dart';
import 'package:medialert/domain/entities/medication.dart';
import 'package:medialert/domain/entities/medication_intake.dart';
import 'package:medialert/domain/repositories/medication_repository.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MedicationRepositoryImpl({
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Medication>>> getMedications() async {
    try {
      final medications = await localDataSource.getMedications();
      return Right(medications);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Medication>> getMedicationById(String id) async {
    try {
      final medication = await localDataSource.getMedicationById(id);
      return Right(medication);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveMedication(Medication medication) async {
    try {
      await localDataSource.saveMedication(
        MedicationModel.fromEntity(medication),
      );
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedication(String id) async {
    try {
      await localDataSource.deleteMedication(id);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateMedication(Medication medication) async {
    try {
      await localDataSource.updateMedication(
        MedicationModel.fromEntity(medication),
      );
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<MedicationIntake>>> getMedicationIntakes() async {
    try {
      final intakes = await localDataSource.getMedicationIntakes();
      return Right(intakes);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveMedicationIntake(
      MedicationIntake intake) async {
    try {
      await localDataSource.saveMedicationIntake(
        MedicationIntakeModel.fromEntity(intake),
      );
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateMedicationIntake(
      MedicationIntake intake) async {
    try {
      await localDataSource.updateMedicationIntake(
        MedicationIntakeModel.fromEntity(intake),
      );
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<MedicationIntake>>> getFilteredIntakes({
    String? medicationName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final intakes = await localDataSource.getFilteredIntakes(
        medicationName: medicationName,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(intakes);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
