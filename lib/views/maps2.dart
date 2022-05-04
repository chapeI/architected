import 'package:architectured/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Maps2 extends StatefulWidget {
  const Maps2({Key? key}) : super(key: key);

  @override
  State<Maps2> createState() => _Maps2State();
}

class _Maps2State extends State<Maps2> {
  late GoogleMapController googleMapController;
  @override
  Widget build(BuildContext context) {
    var event = Provider.of<EventModel>(context);

    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: LatLng(30, 30)),
        onMapCreated: (GoogleMapController controller) async {
          googleMapController = controller;
          Position position = await Geolocator.getCurrentPosition();
          print(position);
          googleMapController
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                  target: LatLng(
                    position.latitude,
                    position.longitude,
                  ),
                  zoom: 15)));
        },
      ),
    );
  }
}
