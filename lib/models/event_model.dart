import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  GeoPoint? location;
  String? address;
  String? placeName;
  String lastMessage;
  UserInfo me;
  UserInfo friend;
  EventModel({
    required this.lastMessage,
    required this.me,
    required this.friend,
    this.address,
    this.placeName,
    this.location,
  });
}

class UserInfo {
  String uid;
  bool broadcasting;
  String userNumber;
  GeoPoint location;

  UserInfo(
      {required this.uid,
      required this.broadcasting,
      required this.location,
      required this.userNumber});
}
