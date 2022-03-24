import 'package:architectured/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel> signIn(email, password) async {
    UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User? user = authResult.user;
    return UserModel(uid: user!.uid, email: email);
  }

  Future<UserModel> getUser() async {
    User? user = _auth.currentUser;
    return UserModel(uid: user!.uid, email: user.email);
  }

  Future<String> get uid async {
    return await _auth.currentUser!.uid;
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
