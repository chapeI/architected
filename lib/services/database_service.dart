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

  Stream<List<UserModel>> get allUsers {
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

  Stream<List<SimpleUserModel>> get simpleUsers {
    return usersCollection.snapshots().map((snapshot) {
      List<SimpleUserModel> allSimpleUsers = allSimpleList(snapshot);
      return allSimpleUsers;
    });
  }

  List<SimpleUserModel> allSimpleList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => SimpleUserModel(email: doc['email'], uid: doc.id))
        .toList();
  }

  void removeMyUid(List<UserModel> users) async {
    final user = _authService.me;
    users.removeWhere((user) => user.uid == user.uid);
  }

  Future<void> removeMyFriends(List<UserModel> users) async {}

  Future<void> addFriend(String uid) async {
    final me = await _authService.me;
    _database.collection('chats').add({'user1': 'uid1', 'user2': 'uid2'}).then(
        (documentReference) async {
      await usersCollection
          .doc(me.uid)
          .collection('friends')
          .doc('other_users_uid')
          .set({
        'email': 'user1_email',
        'name': 'user1_name',
        'chatsID': documentReference
      }).then((some_response) {
        usersCollection
            .doc('other_users_uid')
            .collection('friends')
            .doc(me.uid)
            .set({
          'email': 'my_email',
          'name': 'my_name',
          'chatsID': documentReference
        });
      });
    });
  }

  Future<void> addSimpleFriend(SimpleUserModel friend) async {
    final me = _authService.me;
    // print('test: {$me.email}');
    _database.collection('chats').add(
        {'user1': me.uid, 'user2': friend.uid}).then((documentReference) async {
      await usersCollection
          .doc(me.uid)
          .collection('friends')
          .doc(friend.uid)
          .set({'email': friend.email, 'chatsID': documentReference}).then(
              (someResponse) {
        usersCollection
            .doc(friend.uid)
            .collection('friends')
            .doc(me.uid)
            .set({'email': me.email, 'chatsID': documentReference});
      });
    });
  }

  Stream<List<SimpleUserModel>> get myFriends {
    final me = _authService.me;
    print('test: ${me.email}');
    return usersCollection
        .doc(me.uid)
        .collection('friends')
        .snapshots()
        .map((snapshot) {
      return mySimpleFriendsList(snapshot);
    });
  }

  List<SimpleUserModel> mySimpleFriendsList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => SimpleUserModel(email: doc['email'], uid: doc.id))
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
