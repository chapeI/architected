import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String uid;
  String text;
  String sender;
  Timestamp timestamp;
  ChatModel(
      {required this.text,
      required this.uid,
      required this.sender,
      required this.timestamp});
}
