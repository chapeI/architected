import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final double lat;
  final double lng;

  LocationModel({required this.lat, required this.lng});

  factory LocationModel.fromJson(Map<dynamic, dynamic> parsedJson) {
    return LocationModel(lat: parsedJson['lat'], lng: parsedJson['lng']);
  }
}
