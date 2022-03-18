import 'package:architectured/locator.dart';
import 'package:architectured/repos/auth_repo.dart';
import 'package:architectured/repos/storage_repo.dart';
import 'package:architectured/user_model.dart';

class UserController {
  // add lates? for UserController errors
  late UserModel _currentUser;
  late Future init;
  final AuthRepo _authRepo = locator.get<AuthRepo>();
  final StorageRepo _storageRepo = locator.get<StorageRepo>();

  UserController() {
    init = initUser();
  }

  Future<UserModel> initUser() async {
    _currentUser = await _authRepo.getUser();
    return _currentUser;
  }

  UserModel get currentUser => _currentUser;

  Future<String> getDownloadUrl() async {
    return await _storageRepo.getUserProfileImage(currentUser.uid);
  }

  Future<void> signIn(email, password) async {
    _currentUser = await _authRepo.signIn(email, password);
    _currentUser.avatarUrl = await getDownloadUrl();
  }

  Future<void> register(email, password) async {
    _currentUser = await _authRepo.register(email, password);
  }
}
