import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? email;
  String? displayName;
  String? avatarUrl;
  DocumentReference? chatsID;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.chatsID,
  });
}
