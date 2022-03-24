import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/singletons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final _authService = getIt.get<AuthService>();
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  void addToUsersCollection(UserModel user) async {
    _database.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'avatarUrl': user.avatarUrl
    });
  }

  Stream<List<UserModel>> get all {
    return usersCollection.snapshots().map((snapshot) {
      List<UserModel> allUsers = allList(snapshot);
      removeMyUid(allUsers);
      removeMyFriends(allUsers);
      return allUsers;
    });
  }

  List<UserModel> allList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => UserModel(
            displayName: doc['displayName'],
            email: doc['email'],
            uid: doc.id,
            avatarUrl: doc['avatarUrl']))
        .toList();
  }

  void removeMyUid(List<UserModel> users) async {
    final uid = await _authService.uid;
    print('uid test: $uid');
    users.removeWhere((user) => user.uid == uid);
  }

  void removeMyFriends(List<UserModel> users) async {}
}
