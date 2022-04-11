class EventModel {
  String? event;
  String? time;
  String? location;
  String? picture;
  String lastMessage;
  EventModel(
      {this.event,
      required this.lastMessage,
      this.time,
      this.location,
      this.picture});
}
