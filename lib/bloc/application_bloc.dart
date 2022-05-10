import 'dart:async';

import 'package:architectured/models/place_model.dart';
import 'package:architectured/services/location_service.dart';
import 'package:flutter/cupertino.dart';

class ApplicationBloc with ChangeNotifier {
  List<PlaceSearch>? searchResults;
  searchPlaces(searchTerm) async {
    searchResults = await LocationService().getAutoComplete(searchTerm);
    notifyListeners();
  }

  var selectedLocation = StreamController<PlaceModel>();

  setSelectedLocation(String placeId) async {
    selectedLocation.add(await LocationService().getPlace2(placeId));
    searchResults = null;
    notifyListeners();
  }

  @override
  void dispose() {
    selectedLocation.close();
    super.dispose();
  }
}
