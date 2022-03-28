import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String text;
  String sender;
  Timestamp timestamp;
  ChatModel(
      {required this.text, required this.sender, required this.timestamp});
}
