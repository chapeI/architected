import 'package:architectured/singletons.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/user_model.dart';

class UserController {
  late UserModel _currentUser;
  final AuthService _authService = getIt.get<AuthService>();

  // WHY?
  late Future<UserModel> init;
  UserController() {
    init = initUserController();
  }
  Future<UserModel> initUserController() async {
    _currentUser = await _authService.getUser();
    return _currentUser;
  }
  // --

  UserModel get currentUser => _currentUser;

  Future<void> signIn(email, password) async {
    _currentUser = await _authService.signIn(email, password);
  }
}
