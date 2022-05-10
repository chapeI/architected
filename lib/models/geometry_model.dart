import 'package:architectured/models/location_model.dart';

class GeometryModel {
  final LocationModel locationModel;

  GeometryModel({required this.locationModel});
  factory GeometryModel.fromJson(Map<dynamic, dynamic> parsedJson) {
    return GeometryModel(
        locationModel: LocationModel.fromJson(parsedJson['location']));
  }
}
