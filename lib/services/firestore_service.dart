import 'package:architectured/models/chat_model.dart';
import 'package:architectured/models/event_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/singletons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authService = getIt.get<AuthService>();
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  // turn this into eventChatService.dart at some point
  CollectionReference chatCollection(String docid) {
    return _firestore.collection('chats').doc(docid).collection('chat');
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
    }).then(
      (value) {
        _firestore
            .collection('chats')
            .doc(chatId)
            .update({'lastMessage': message});
      },
    );
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
    _firestore.collection('chats').add({
      'user1': {'uid': me.uid, 'broadcasting': false},
      'user2': {'uid': friend.uid, 'broadcasting': false},
      'lastMessage': 'Start chatting with ${friend.displayName}!',
      'event': null,
      'location': null,
      'hour': null,
      'minute': null,
      'address': null,
      'placeName': null,
    }).then((documentReference) async {
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
              displayName: doc['displayName'],
              chatsID: doc['chatsID'] ?? 'badChatsid',
              avatarUrl: doc['avatarUrl'] ?? 'bad avatarUrl'),
        )
        .toList();
  }

  // anoops way, time to do it properly
  Future<void> addEvent(DocumentReference docRef, eventName) async {
    return await eventCollection.doc(docRef.id).update({'event': eventName});
  }

  void deleteEvent(DocumentReference doc) {
    eventCollection.doc(doc.id).update({
      'event': null,
      'minute': null,
      'hour': null,
      'location': null,
      'placeName': null,
      'address': null,
    }).whenComplete(() {});
  }

  CollectionReference get eventCollection {
    return _firestore.collection('chats'); // yup poor naming
  }

// returning Stream<EventModel>
  Stream<EventModel> events(DocumentReference doc) {
    return eventCollection.doc(doc.id).snapshots().map((snapshot) {
      return _events(snapshot);
    });
  }

  EventModel _events(DocumentSnapshot snapshot) {
    var myUid = _authService.me;
    var me;
    var friend;

    if (snapshot['user1.uid'] == myUid.uid) {
      me = 'user1';
      friend = 'user2';
    } else {
      me = 'user2';
      friend = 'user1';
    }

    // ignore: curly_braces_in_flow_control_structures
    return EventModel(
      me: UserInfo(
          uid: snapshot['$me.uid'],
          broadcasting: snapshot['$me.broadcasting'],
          userNumber: me),
      friend: UserInfo(
          uid: snapshot['$friend.uid'],
          broadcasting: snapshot['$friend.broadcasting'],
          userNumber: friend),
      event: snapshot['event'],
      hour: snapshot['hour'],
      minute: snapshot['minute'],
      address: snapshot['address'],
      placeName: snapshot['placeName'],
      location: snapshot['location'],
      lastMessage: snapshot['lastMessage'] ?? 'lastmessageDebug',
    );
  }

  void addEventTime(DocumentReference doc, TimeOfDay time) {
    eventCollection
        .doc(doc.id)
        .update({'hour': time.hour, 'minute': time.minute});
  }

  void addLocation(String doc, LatLng latLng, name, address) {
    eventCollection.doc(doc).update({
      'placeName': name,
      'address': address,
      'location': GeoPoint(latLng.latitude, latLng.longitude)
    });
  }

  void toggleMyBroadcast(String chatId, bool broadcast, UserInfo me) {
    eventCollection.doc(chatId).update({
      '${me.userNumber}.broadcasting': !broadcast,
    });
  }
}
