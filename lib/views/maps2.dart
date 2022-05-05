import 'package:architectured/models/event_model.dart';
import 'package:architectured/services/firestore_service.dart';
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
  Set<Marker> _m1 = {};
  Set<Marker> _m2 = {};
  bool broadcast = true;

  @override
  Widget build(BuildContext context) {
    var event = Provider.of<EventModel>(context);

    // checkMyMarker()
    // me.broadcast ? green : blue
    // onPress => broadcast

    // checkFriend()
    // locatio

    // checkLocation()

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.sync),
          onPressed: () {
            setState(() {
              broadcast = !broadcast;
            });
          }),
      body: GoogleMap(
        zoomControlsEnabled: false,
        initialCameraPosition:
            CameraPosition(target: LatLng(43.6426, -79.3871), zoom: 12),
        markers: event.me.broadcasting ||
                event.friend.broadcasting ||
                event.location != null
            ? _m1
            : _m2,
        onMapCreated: (GoogleMapController controller) async {
          _setM1(event);
          _setM2(event);
        },
      ),
    );
  }

  _setM1(EventModel event) {
    _m1 = {};
    _m1.add(Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        markerId: MarkerId('marker 1'),
        position: LatLng(43.6426, -79.3871),
        onTap: () {
          print('entered setm1');
          FirestoreService()
              .toggleMyBroadcast('fJFza8YUFQNXawP0XO3H', false, event.me);
        }));
  }

  _setM2(EventModel event) {
    _m2 = {};
    _m2.add(Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        markerId: MarkerId('marker 2'),
        position: LatLng(43.6426, -79.3871),
        onTap: () {
          print('entered setm2');
          FirestoreService()
              .toggleMyBroadcast('fJFza8YUFQNXawP0XO3H', true, event.me);
        }));
  }
}
