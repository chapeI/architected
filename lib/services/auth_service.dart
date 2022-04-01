import 'package:architectured/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel get me {
    User? user = _auth.currentUser;
    return UserModel(
        uid: user!.uid,
        email: user.email,
        displayName: user.displayName,
        avatarUrl: user.photoURL);
  }

  Future<UserModel> signIn(email, password) async {
    UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User? user = authResult.user;
    return UserModel(uid: user!.uid, email: email);
  }

  Future<String?> register(email, password, name, imagePath) async {
    UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = authResult.user;
    // user!.updatePhotoURL(imagePath.toString());
    user!.updateDisplayName(name);
    // await Future.delayed(const Duration(seconds: 2));
    return user.uid;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void updateAvatarUrl(String url) {
    _auth.currentUser!.updatePhotoURL(url);
  }
}

class Auth {
  final _auth = FirebaseAuth.instance;

  String? _getUid(User user) {
    return user == null ? null : user.uid;
  }

  Stream<String> get stream {
    return _auth.authStateChanges().map((User? u) => u!.uid);
  }
}

class uidModel {
  String uid;
  uidModel({required this.uid});
}
