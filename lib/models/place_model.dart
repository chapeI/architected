import 'package:architectured/models/geometry_model.dart';

class PlaceModel {
  final GeometryModel geometryModel;
  final String name;
  final String vicinity;

  PlaceModel(
      {required this.geometryModel,
      required this.name,
      required this.vicinity});

  factory PlaceModel.fromJson(Map<String, dynamic> parsedJson) {
    return PlaceModel(
        geometryModel: GeometryModel.fromJson(parsedJson['geometry']),
        name: parsedJson['formatted_address'],
        vicinity: parsedJson['vicinity']);
  }
}
