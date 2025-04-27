import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/core/usecases/usecase.dart';
import 'package:medialert/domain/entities/cima_medication.dart';
import 'package:medialert/domain/repositories/cima_repository.dart';

class SearchCimaMedications
    implements UseCase<List<CimaMedication>, SearchParams> {
  final CimaRepository repository;

  SearchCimaMedications(this.repository);

  @override
  Future<Either<Failure, List<CimaMedication>>> call(
      SearchParams params) async {
    return await repository.searchMedications(params.query);
  }
}

class SearchParams extends Equatable {
  final String query;

  const SearchParams({required this.query});

  @override
  List<Object> get props => [query];
}
