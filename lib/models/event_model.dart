import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String? event;
  int? hour;
  int? minute;
  GeoPoint? location;
  String? address;
  String? placeName;
  String? picture;
  String lastMessage;
  UserInfo me;
  UserInfo friend;
  EventModel(
      {this.event,
      required this.lastMessage,
      required this.me,
      required this.friend,
      this.minute,
      this.address,
      this.placeName,
      this.hour,
      this.location,
      this.picture});
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
