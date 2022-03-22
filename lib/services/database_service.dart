import 'package:architectured/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  void addToUsersCollection(UserModel user) async {
    _database.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
    });
  }
}
