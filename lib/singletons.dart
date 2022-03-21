import 'package:architectured/services/auth_service.dart';
import 'package:architectured/user_controller.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServices() {
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<UserController>(UserController());
}
