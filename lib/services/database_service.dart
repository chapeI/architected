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

  Future<void> removeMyFriends(List<UserModel> users) async {}

  Future<void> addFriend() async {
    final uid = await _authService.uid;
    _database.collection('chats').add({'user1': 'uid1', 'user2': 'uid2'}).then(
        (documentReference) async {
      await usersCollection
          .doc(uid)
          .collection('friends')
          .doc('other_users_uid')
          .set({
        'email': 'user1_email',
        'name': 'user2_email',
        'chatsID': documentReference
      }).then((some_response) {
        usersCollection
            .doc('other_users_uid')
            .collection('friends')
            .doc(uid)
            .set({
          'email': 'my_email',
          'name': 'my_name',
          'chatsID': documentReference
        });
      });
    });
  }

  Stream<List<SimpleUserModel>> get myFriends {
    // final uid = await _authService.uid;
    final uid = 'WhDSNfYO26hkykJ7zFwKSOLLS312';
    return usersCollection
        .doc(uid)
        .collection('friends')
        .snapshots()
        .map((snapshot) {
      return mySimpleFriendsList(snapshot);
    });
  }

  List<SimpleUserModel> mySimpleFriendsList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => SimpleUserModel(email: doc['email']))
        .toList();
  }

  List<UserModel> myFriendsList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => UserModel(
            email: doc['email'],
            uid: doc.id,
            avatarUrl: doc['avatarUrl'],
            displayName: doc['displayName']))
        .toList();
  }
}
