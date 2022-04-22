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
  EventModel(
      {this.event,
      required this.lastMessage,
      this.minute,
      this.address,
      this.placeName,
      this.hour,
      this.location,
      this.picture});
}
