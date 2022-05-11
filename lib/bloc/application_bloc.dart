import 'package:architectured/services/location_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ApplicationBloc with ChangeNotifier {
  List<PlaceSearch>? searchResults;
  searchPlaces(searchTerm, LatLng latLng) async {
    searchResults = await LocationService().getAutoComplete(searchTerm, latLng);
    notifyListeners();
  }
}
