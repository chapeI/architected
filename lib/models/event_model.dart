import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String? event;
  int? hour;
  int? minute;
  GeoPoint? location;
  String? picture;
  String lastMessage;
  EventModel(
      {this.event,
      required this.lastMessage,
      this.minute,
      this.hour,
      this.location,
      this.picture});
}
