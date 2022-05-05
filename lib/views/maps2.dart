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
  Set<Marker> _markers = {};
  bool broadcast = true;

  @override
  void initState() {
    super.initState();
    // _markers.add(
    //     Marker(position: LatLng(43.6426, -79.3871), markerId: (MarkerId('1'))));
  }

  @override
  Widget build(BuildContext context) {
    var event = Provider.of<EventModel>(context);

    print('looping through markers');
    _markers.forEach((marker) {
      print(marker.markerId);
    });

    final me = _markers.lookup(Marker(markerId: MarkerId('me')));
    print(me);

    if (event.me.broadcasting == true) {
      setState(() {
        _markers = {};
        _markers.add(
          Marker(
              markerId: MarkerId('me'),
              position: LatLng(43.6499, -79.3579),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
              onTap: () {
                FirestoreService()
                    .toggleMyBroadcast('0mdXNlkwnjX304uZPpbJ', false, event.me);
              }),
        );
      });
    } else {
      setState(() {
        _markers = {};
        _markers.add(
          Marker(
              markerId: MarkerId('2'),
              position: LatLng(43.6499, -79.3579),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              onTap: () {
                FirestoreService()
                    .toggleMyBroadcast('0mdXNlkwnjX304uZPpbJ', true, event.me);
              }),
        );
      });
    }

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
        markers: _markers,
        onMapCreated: (GoogleMapController controller) async {
          // not sure if I should set markers here or in initState
        },
      ),
    );
  }
}
