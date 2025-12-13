import 'package:get_it/get_it.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:inkstreak/data/services/api_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(DioClient.createDio()),
  );
}
