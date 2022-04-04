import 'package:architectured/models/chat_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/singletons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authService = getIt.get<AuthService>();
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  // turn this into eventChatService.dart at some point
  CollectionReference chatCollection(String docid) {
    return _firestore.collection('chats').doc(docid).collection('chat');
  }

  CollectionReference eventCollection() {
    return _firestore.collection('chats'); // yup poor naming
  }

  Stream<List<ChatModel>> getChats(UserModel friend) {
    return chatCollection(friend.chatsID!.id)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => chatList(snapshot));
  }

  List<ChatModel> chatList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => ChatModel(
            text: doc['text'],
            uid: doc['uid'],
            sender: doc['sender'],
            timestamp: doc['timestamp']))
        .toList();
  }

  sendMessage(String message, String chatId) {
    chatCollection(chatId).add({
      'text': message,
      'uid': _authService.me.uid,
      'sender': _authService.me.displayName,
      'timestamp': FieldValue.serverTimestamp()
    });
  }
  // eventchat_service.dart end

  void addNewlyRegisteredToUsersCollection(UserModel user) async {
    _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'avatarUrl': user.avatarUrl
    });
  }

  Future<void> addFriend(UserModel friend) async {
    final me = _authService.me;
    _firestore.collection('chats').add(
        {'user1': me.uid, 'user2': friend.uid}).then((documentReference) async {
      // print('testing addfriend');
      // print(friend.displayName);
      // print(friend.email);
      // print(friend.toString());
      await _usersCollection
          .doc(me.uid)
          .collection('friends')
          .doc(friend.uid)
          .set({
        'email': friend.email,
        'displayName': friend.displayName,
        'chatsID': documentReference,
        'avatarUrl': friend.avatarUrl
      }).then((someResponse) {
        _usersCollection.doc(friend.uid).collection('friends').doc(me.uid).set({
          'email': me.email,
          'displayName': me.displayName,
          'chatsID': documentReference,
          'avatarUrl': me.avatarUrl
        });
      });
    });
  }

  Future<List<UserModel>> get addUserList {
    return _usersCollection.get().then((QuerySnapshot snapshot) async {
      List<UserModel> all = snapshot.docs.map((doc) {
        return UserModel(
            email: doc['email'],
            uid: doc.id,
            displayName: doc['displayName'],
            avatarUrl: doc['avatarUrl']);
      }).toList();
      removeMyUid(all);
      return await removeFriends(all);
    });
  }

  void removeMyUid(List<UserModel> users) async {
    final me = _authService.me;
    users.removeWhere((user) => user.uid == me.uid);
  }

  Future<List<UserModel>> removeFriends(List<UserModel> u) async {
    List<UserModel> friends = [];
    List<UserModel> users = u;

    await friendsCollection.get().then((snapshot) {
      friends = toList(snapshot);
    });

    friends.forEach((friend) {
      users.removeWhere((user) => user.uid == friend.uid);
    });

    return users;
  }

  List<UserModel> toList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => UserModel(
            email: doc['email'], uid: doc.id, avatarUrl: doc['avatarUrl']))
        .toList();
  }

  CollectionReference get friendsCollection {
    final me = _authService.me;
    return _usersCollection.doc(me.uid).collection('friends');
  }

  Stream<List<UserModel>> get friends {
    return friendsCollection.snapshots().map((snapshot) {
      return friendsList(snapshot);
    });
  }

  List<UserModel> friendsList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map(
          (doc) => UserModel(
              email: doc['email'],
              uid: doc.id,
              chatsID: doc['chatsID'] ?? 'badChatsid',
              avatarUrl: doc['avatarUrl'] ?? 'bad avatarUrl'),
        )
        .toList();
  }

  // anoops way, time to do it properly
  Future<void> addEvent(DocumentReference docRef, eventName) async {
    return eventCollection().doc(docRef.id).update({'event': eventName});
  }
}
