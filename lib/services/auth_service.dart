import 'package:architectured/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel get me {
    User? user = _auth.currentUser;
    return UserModel(uid: user!.uid, email: user.email);
  }

  Future<UserModel> signIn(email, password) async {
    UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User? user = authResult.user;
    return UserModel(uid: user!.uid, email: email);
  }

  Future<String?> register(email, password) async {
    UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = authResult.user;
    return user!.uid;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
