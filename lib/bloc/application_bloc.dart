import 'package:architectured/services/location_service.dart';
import 'package:flutter/cupertino.dart';

class ApplicationBloc with ChangeNotifier {
  List<PlaceSearch>? searchResults;
  searchPlaces(searchTerm) async {
    searchResults = await LocationService().getAutoComplete(searchTerm);
    notifyListeners();
  }
}
