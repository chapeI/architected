import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/database_service.dart';
import 'package:architectured/services/storage_service.dart';
import 'package:architectured/services/user_controller.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServices() {
  getIt.registerSingleton<DatabaseService>(DatabaseService());
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<UserController>(UserController());
  getIt.registerSingleton<StorageService>(StorageService());
}
