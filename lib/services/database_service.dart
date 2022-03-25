import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/singletons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final _authService = getIt.get<AuthService>();
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  void addNewlyRegisteredToUsersCollection(UserModel user) async {
    _database.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'avatarUrl': user.avatarUrl
    });
  }

  Stream<List<SimpleUserModel>> get simpleUsers {
    return usersCollection.snapshots().map((snapshot) {
      List<SimpleUserModel> allSimpleUsers = allSimpleList(snapshot);
      removeMyUid(allSimpleUsers);
      removeFriend(allSimpleUsers);
      return allSimpleUsers;
    });
  }

  List<SimpleUserModel> allSimpleList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => SimpleUserModel(email: doc['email'], uid: doc.id))
        .toList();
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

// removing users from addFriendsScreen(), glitchy
  void removeMyUid(List<SimpleUserModel> users) async {
    final me = _authService.me;
    users.removeWhere((user) => user.uid == me.uid);
  }

  void removeFriend(List<SimpleUserModel> users) {
    final me = _authService.me;
    usersCollection
        .doc(me.uid)
        .collection('friends')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        users.removeWhere((user) {
          return user.uid == doc.id;
        });
      });
    });
  }
}
