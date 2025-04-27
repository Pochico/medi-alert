import 'package:dartz/dartz.dart';
import 'package:medialert/core/error/exceptions.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/core/network/network_info.dart';
import 'package:medialert/data/datasources/cima_remote_datasource.dart';
import 'package:medialert/domain/entities/cima_medication.dart';
import 'package:medialert/domain/repositories/cima_repository.dart';

class CimaRepositoryImpl implements CimaRepository {
  final CimaRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CimaRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CimaMedication>>> searchMedications(
      String query) async {
    if (await networkInfo.isConnected) {
      try {
        final medications = await remoteDataSource.searchMedications(query);
        return Right(medications);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, CimaMedication>> getMedicationDetails(
      String registrationNumber) async {
    if (await networkInfo.isConnected) {
      try {
        final medication =
            await remoteDataSource.getMedicationDetails(registrationNumber);
        return Right(medication);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
