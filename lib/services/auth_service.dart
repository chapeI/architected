import 'package:architectured/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel> signIn(email, password) async {
    UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User? user = authResult.user;
    return UserModel(uid: user!.uid);
  }

  Future<UserModel> getUser() async {
    User? user = await _auth.currentUser;
    return UserModel(uid: user!.uid);
  }

  Future<UserModel> register(email, password) async {
    UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = authResult.user;
    return UserModel(uid: user!.uid);
  }
}
