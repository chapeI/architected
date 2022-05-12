import 'package:architectured/models/geometry_model.dart';

class PlaceModel {
  final GeometryModel geometryModel;
  final String name;
  final String vicinity;
  final String address;

  PlaceModel(
      {required this.geometryModel,
      required this.name,
      required this.vicinity,
      required this.address});

  factory PlaceModel.fromJson(Map<String, dynamic> parsedJson) {
    return PlaceModel(
        geometryModel: GeometryModel.fromJson(parsedJson['geometry']),
        address: parsedJson['formatted_address'],
        vicinity: parsedJson['vicinity'],
        name: parsedJson['name']);
  }
}
