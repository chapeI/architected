import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:architectured/models/place_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LocationService {
  final key = 'AIzaSyBbtrRS3yVEqJXSgmNgzth-LtUj8p_BKeU';

  Future<String> getPlaceId(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var placeId = json['candidates'][0]['place_id'] as String;

    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    final placeId = await getPlaceId(input);

    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;

    return results;
  }

  Future<PlaceModel> getPlace2(String placeId) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&key=${key}';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;

    return PlaceModel.fromJson(results);
  }

  Future<List<PlaceSearch>> getAutoComplete(
      String search, LatLng latLng) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?key=${key}&input=${search}&location=${latLng.latitude}%2C${latLng.longitude}&radius=500';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['predictions'] as List;
    return results.map((place) => PlaceSearch.fromJson(place)).toList();
  }
}

class PlaceSearch {
  final String desc;
  final String placeId;

  PlaceSearch({required this.desc, required this.placeId});

  factory PlaceSearch.fromJson(Map<String, dynamic> json) {
    return PlaceSearch(desc: json['description'], placeId: json['place_id']);
  }
}
