import 'package:architectured/services/singletons.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/models/user_model.dart';

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

  Future<void> register(email, password) async {
    _currentUser = await _authService.register(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
