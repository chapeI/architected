import 'package:architectured/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthRepo();

  Future<UserModel> register(email, password) async {
    UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = authResult.user;
    return UserModel(user!.uid, displayName: user.displayName);
  }

  Future<UserModel> signIn(email, password) async {
    UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User? user = authResult.user;

    return UserModel(user!.uid, displayName: user.displayName);
  }

  Future<UserModel> getUser() async {
    User? user = await _auth.currentUser!;
    return UserModel(user.uid, displayName: user.displayName);
  }
}
