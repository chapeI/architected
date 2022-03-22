import 'package:architectured/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  void addToUsersCollection(UserModel userModel) {
    _store.collection('users').doc(userModel.uid).set({
      'uid': userModel.uid,
      'email': userModel.email,
      'displayName': userModel.displayName,
      'avatarUrl': userModel.avatarUrl
    });
  }
}
