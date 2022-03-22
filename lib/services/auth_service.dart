import 'package:architectured/services/database_service.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/singletons.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService = getIt.get<DatabaseService>();

  Future<UserModel> signIn(email, password) async {
    UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User? user = authResult.user;
    return UserModel(uid: user!.uid, email: email);
  }

  Future<UserModel> getUser() async {
    User? user = await _auth.currentUser;
    return UserModel(uid: user!.uid, email: user.email);
  }

  Future<UserModel> register(email, password) async {
    UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = authResult.user;
    UserModel userModel = UserModel(uid: user!.uid, email: email);
    _databaseService.addToUsersCollection(userModel);
    return userModel;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
