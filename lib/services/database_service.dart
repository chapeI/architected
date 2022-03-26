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
      // removeMyUid(allSimpleUsers);
      // removeFriend(allSimpleUsers);
      return allSimpleUsers;
    });
  }

  Future<List<SimpleUserModel>> get friendsToAdd {
    return usersCollection.get().then((QuerySnapshot snapshot) async {
      List<SimpleUserModel> all = snapshot.docs.map((doc) {
        return SimpleUserModel(email: doc['email'], uid: doc.id);
      }).toList();
      return await removeFriend(all);
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

  void removeMyUid(List<SimpleUserModel> users) async {
    final me = _authService.me;
    users.removeWhere((user) => user.uid == me.uid);
  }

  Future<List<SimpleUserModel>> removeFriend(List<SimpleUserModel> u) async {
    // print('entered removefriend');
    final me = _authService.me;
    List<SimpleUserModel> friends = [];
    List<SimpleUserModel> users = u;

    await usersCollection
        .doc(me.uid)
        .collection('friends')
        .get()
        .then((snapshot) {
      friends = allSimpleList(snapshot);
    });

    print('quarantine-start');
    users.forEach((element) {
      print(element.email);
    });

    print('removing');
    friends.forEach((friend) {
      users.removeWhere((user) => user.uid == friend.uid);
    });

    print('quarantine-end');
    users.forEach((element) {
      print(element.email);
    });

    return users;
  }
}
