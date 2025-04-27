import 'package:flutter/material.dart';
import 'package:medialert/core/error/failures.dart';
import 'package:medialert/core/usecases/usecase.dart';
import 'package:medialert/data/models/medication_model.dart';
import 'package:medialert/domain/entities/cima_medication.dart';
import 'package:medialert/domain/entities/medication.dart';
import 'package:medialert/domain/entities/medication_intake.dart';
import 'package:medialert/domain/usecases/get_filtered_intakes.dart';
import 'package:medialert/domain/usecases/get_medication_by_id.dart';
import 'package:medialert/domain/usecases/get_medications.dart';
import 'package:medialert/domain/usecases/save_medication.dart';
import 'package:medialert/domain/usecases/save_medication_intake.dart';
import 'package:medialert/domain/usecases/search_cima_medications.dart';
import 'package:medialert/domain/usecases/update_medication.dart';
import 'package:medialert/domain/usecases/update_medication_intake.dart';
import 'package:uuid/uuid.dart';

class MedicationProvider extends ChangeNotifier {
  final GetMedications getMedications;
  final GetMedicationById getMedicationById;
  final SaveMedication saveMedication;
  final UpdateMedication updateMedication;
  final GetFilteredIntakes getFilteredIntakes;
  final SaveMedicationIntake saveMedicationIntake;
  final UpdateMedicationIntake updateMedicationIntake;
  final SearchCimaMedications searchCimaMedications;

  MedicationProvider({
    required this.getMedications,
    required this.getMedicationById,
    required this.saveMedication,
    required this.updateMedication,
    required this.getFilteredIntakes,
    required this.saveMedicationIntake,
    required this.updateMedicationIntake,
    required this.searchCimaMedications,
  });

  List<Medication> _medications = [];
  List<Medication> get medications => _medications;

  List<MedicationIntake> _intakes = [];
  List<MedicationIntake> get intakes => _intakes;

  List<CimaMedication> _searchResults = [];
  List<CimaMedication> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadMedications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getMedications(NoParams());
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
      },
      (medicationModels) {
        _medications = medicationModels
            .map((model) => Medication(
                  id: model.id,
                  name: model.name,
                  dosage: model.dosage,
                  frequency: model.frequency,
                  reminders: model.reminders,
                  notes: model.notes,
                  registrationNumber: model.registrationNumber,
                ))
            .toList();
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required List<DateTime> reminders,
    String? notes,
    String? registrationNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final medication = Medication(
      id: const Uuid().v4(),
      name: name,
      dosage: dosage,
      frequency: frequency,
      reminders: reminders,
      notes: notes,
      registrationNumber: registrationNumber,
    );

    final medicationModel = MedicationModel(
      id: medication.id,
      name: medication.name,
      dosage: medication.dosage,
      frequency: medication.frequency,
      reminders: medication.reminders,
      notes: medication.notes,
      registrationNumber: medication.registrationNumber,
    );

    final result =
        await saveMedication(SaveMedicationParams(medication: medicationModel));
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
      },
      (_) {
        _medications.add(medication);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> editMedication({
    required String id,
    required String name,
    required String dosage,
    required String frequency,
    required List<DateTime> reminders,
    String? notes,
    String? registrationNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final medicationIndex = _medications.indexWhere((med) => med.id == id);
    if (medicationIndex != -1) {
      final updatedMedication = _medications[medicationIndex].copyWith(
        name: name,
        dosage: dosage,
        frequency: frequency,
        reminders: reminders,
        notes: notes,
        registrationNumber: registrationNumber,
      );

      final updatedMedicationModel = MedicationModel(
        id: updatedMedication.id,
        name: updatedMedication.name,
        dosage: updatedMedication.dosage,
        frequency: updatedMedication.frequency,
        reminders: updatedMedication.reminders,
        notes: updatedMedication.notes,
        registrationNumber: updatedMedication.registrationNumber,
      );

      final result = await updateMedication(
        UpdateMedicationParams(medication: updatedMedicationModel),
      );

      result.fold(
        (failure) {
          _errorMessage = _mapFailureToMessage(failure);
        },
        (_) {
          _medications[medicationIndex] = updatedMedication;
        },
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMedicationIntakes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getFilteredIntakes(const FilterParams());
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
      },
      (intakes) {
        _intakes = intakes;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> filterIntakes({
    String? medicationName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getFilteredIntakes(
      FilterParams(
        medicationName: medicationName,
        startDate: startDate,
        endDate: endDate,
      ),
    );

    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
      },
      (filteredIntakes) {
        _intakes = filteredIntakes;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> recordMedicationIntake({
    required String medicationId,
    required String medicationName,
    required String dosage,
    required DateTime intakeTime,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final intake = MedicationIntake(
      id: const Uuid().v4(),
      medicationId: medicationId,
      medicationName: medicationName,
      dosage: dosage,
      intakeTime: intakeTime,
      taken: true,
    );

    final result = await saveMedicationIntake(
      SaveIntakeParams(intake: intake),
    );

    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
      },
      (_) {
        _intakes.add(intake);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchCimaMedicationsByName(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await searchCimaMedications(SearchParams(query: query));
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _searchResults = [];
      },
      (medications) {
        _searchResults = medications;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Error de servidor. Inténtalo de nuevo más tarde.';
      case CacheFailure:
        return 'Error de almacenamiento local. Reinicia la aplicación.';
      case NetworkFailure:
        return 'Sin conexión a Internet. Verifica tu conexión.';
      default:
        return 'Error inesperado. Inténtalo de nuevo.';
    }
  }
}
