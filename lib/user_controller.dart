import 'package:architectured/singletons.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/user_model.dart';

class UserController {
  late UserModel _currentUser;
  AuthService _authService = getIt.get<AuthService>();
  UserController() {}

  Future<UserModel> signIn(email, password) async {
    _currentUser = await _authService.signIn(email, password);
    return _currentUser;
  }
}
