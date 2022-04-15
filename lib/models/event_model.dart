class EventModel {
  String? event;
  int? hour;
  int? minute;
  String? location;
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
