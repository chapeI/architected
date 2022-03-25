import 'package:architectured/services/database_service.dart';
import 'package:architectured/services/singletons.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/storage_service.dart';

class UserController {
  late UserModel _currentUser;
  final AuthService _authService = getIt.get<AuthService>();
  final StorageService _storageService = getIt.get<StorageService>();
  final DatabaseService _databaseService = getIt.get<DatabaseService>();

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

  Future<void> register(email, password, name, imagePath) async {
    String? uid = await _authService.register(email, password);
    print('usercontroller._authService.register(): $uid  <- cant be null');
    var url = await _storageService.uploadFile(uid!, imagePath);
    UserModel userModel =
        UserModel(uid: uid, email: email, displayName: name, avatarUrl: url);
    _databaseService.addNewlyRegisteredToUsersCollection(userModel);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
