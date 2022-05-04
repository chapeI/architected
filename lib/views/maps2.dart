import 'package:architectured/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  late Position myPosition;
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    var event = Provider.of<EventModel>(context);
    // print('debg');
    // print(event.me.uid);
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(43.6532, -79.3832), zoom: 12), // toronto
        onMapCreated: (GoogleMapController controller) async {
          googleMapController = controller;
          _moveToMyPosition();
        },
        markers: _markers,
      ),
    );
  }

  _moveToMyPosition() async {
    myPosition = await Geolocator.getCurrentPosition();
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              myPosition.latitude,
              myPosition.longitude,
            ),
            zoom: 15)));
    _dropMarker();
  }

  _dropMarker() {
    // var event = Provider.of<EventModel>(context);
    // print('debug');
    // print(event.me.uid);
    _markers.add(
      Marker(
          markerId: MarkerId('my position'),
          infoWindow: InfoWindow(title: 'helo'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () {
            print('i can be tapped');
          },
          position: LatLng(myPosition.latitude, myPosition.longitude)),
    );
    setState(() {
      print('dropping marker');
    });
  }
}
