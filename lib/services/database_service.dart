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

  Future<void> addFriend(UserModel friend) async {
    final me = _authService.me;
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

  Stream<List<UserModel>> get myFriends {
    final me = _authService.me;
    return usersCollection
        .doc(me.uid)
        .collection('friends')
        .snapshots()
        .map((snapshot) {
      return toList(snapshot);
    });
  }

  Future<List<UserModel>> get addUserList {
    return usersCollection.get().then((QuerySnapshot snapshot) async {
      List<UserModel> all = snapshot.docs.map((doc) {
        return UserModel(email: doc['email'], uid: doc.id);
      }).toList();
      removeMyUid(all);
      return await removeMyFriends(all);
    });
  }

  void removeMyUid(List<UserModel> users) async {
    final me = _authService.me;
    users.removeWhere((user) => user.uid == me.uid);
  }

  Future<List<UserModel>> removeMyFriends(List<UserModel> u) async {
    final me = _authService.me;
    List<UserModel> friends = [];
    List<UserModel> users = u;

    await usersCollection
        .doc(me.uid)
        .collection('friends')
        .get()
        .then((snapshot) {
      friends = toList(snapshot);
    });

    friends.forEach((friend) {
      users.removeWhere((user) => user.uid == friend.uid);
    });

    return users;
  }

  List<UserModel> toList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => UserModel(email: doc['email'], uid: doc.id))
        .toList();
  }
}
