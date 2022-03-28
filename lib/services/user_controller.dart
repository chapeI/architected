import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/services/singletons.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/storage_service.dart';

class UserController {
  late UserModel _currentUser;
  final AuthService _auth = getIt.get<AuthService>();
  final StorageService _storage = getIt.get<StorageService>();
  final FirestoreService _firestore = getIt.get<FirestoreService>();

  late Future<UserModel> init;
  UserController() {
    init = initUserController();
  }
  Future<UserModel> initUserController() async {
    _currentUser = _auth.me;
    return _currentUser;
  }

  UserModel get currentUser => _currentUser;

  Future<void> signIn(email, password) async {
    _currentUser = await _auth.signIn(email, password);
  }

  Future<void> register(email, password, name, imagePath) async {
    String? uid = await _auth.register(email, password, name, imagePath);
    // print('usercontroller._authService.register(): $uid  <- cant be null');
    var url = await _storage.uploadFile(uid!, imagePath);
    UserModel userModel =
        UserModel(uid: uid, email: email, displayName: name, avatarUrl: url);
    _auth.updateAvatarUrl(url);
    _firestore.addNewlyRegisteredToUsersCollection(userModel);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
