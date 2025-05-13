import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:medialert/core/network/network_info.dart';
import 'package:medialert/core/services/alarm_service.dart';
import 'package:medialert/core/services/navigation_service.dart';
import 'package:medialert/core/services/notification_service.dart';
import 'package:medialert/data/datasources/cima_remote_datasource.dart';
import 'package:medialert/data/datasources/medication_local_datasource.dart';
import 'package:medialert/data/repositories/cima_repository_impl.dart';
import 'package:medialert/data/repositories/medication_repository_impl.dart';
import 'package:medialert/domain/repositories/cima_repository.dart';
import 'package:medialert/domain/repositories/medication_repository.dart';
import 'package:medialert/domain/usecases/get_filtered_intakes.dart';
import 'package:medialert/domain/usecases/get_medication_by_id.dart';
import 'package:medialert/domain/usecases/get_medications.dart';
import 'package:medialert/domain/usecases/save_medication.dart';
import 'package:medialert/domain/usecases/save_medication_intake.dart';
import 'package:medialert/domain/usecases/search_cima_medications.dart';
import 'package:medialert/domain/usecases/update_medication.dart';
import 'package:medialert/domain/usecases/update_medication_intake.dart';
import 'package:medialert/presentation/providers/medication_provider.dart';
import 'package:medialert/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Providers
  sl.registerFactory(
    () => MedicationProvider(
      getMedications: sl(),
      getMedicationById: sl(),
      saveMedication: sl(),
      updateMedication: sl(),
      getFilteredIntakes: sl(),
      saveMedicationIntake: sl(),
      updateMedicationIntake: sl(),
      searchCimaMedications: sl(),
      notificationService: sl(),
      alarmService: sl(),
    ),
  );

  sl.registerFactory(
    () => SettingsProvider(
      sharedPreferences: sl(),
      notificationService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMedications(sl()));
  sl.registerLazySingleton(() => GetMedicationById(sl()));
  sl.registerLazySingleton(() => SaveMedication(sl()));
  sl.registerLazySingleton(() => UpdateMedication(sl()));
  sl.registerLazySingleton(() => GetFilteredIntakes(sl()));
  sl.registerLazySingleton(() => SaveMedicationIntake(sl()));
  sl.registerLazySingleton(() => UpdateMedicationIntake(sl()));
  sl.registerLazySingleton(() => SearchCimaMedications(sl()));
  sl.registerLazySingleton(() => NavigationService());
  sl.registerLazySingleton(() => AlarmService());

  // Repositories
  sl.registerLazySingleton<MedicationRepository>(
    () => MedicationRepositoryImpl(
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<CimaRepository>(
    () => CimaRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Servicios
  final notificationService = NotificationService();
  await notificationService.init();
  sl.registerLazySingleton(() => notificationService);

  // Data sources
  sl.registerLazySingleton<MedicationLocalDataSource>(
    () => MedicationLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<CimaRemoteDataSource>(
    () => CimaRemoteDataSourceImpl(
      client: sl(),
    ),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectionChecker: sl(),
    ),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
}
