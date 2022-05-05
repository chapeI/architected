import 'package:architectured/models/event_model.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/services/user_controller.dart';
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
  LatLng toronto = LatLng(43.6532, -79.3832);
  late Position myPosition;
  Set<Marker> _markers = {};
  // ignore: prefer_final_fields
  Set<Marker> _m2 = {
    Marker(
        markerId: MarkerId('m2'),
        position: LatLng(43.6532, -79.3832),
        infoWindow: InfoWindow(title: 'toronto'),
        onTap: toggleTest,
  };

  bool test = true;

  @override
  Widget build(BuildContext context) {
    var event = Provider.of<EventModel>(context);
    print('build test $test');
    return Scaffold(
      appBar: AppBar(title: Text(event.me.broadcasting.toString())),
      floatingActionButton: FloatingActionButton(onPressed: () {
        FirestoreService().toggleMyBroadcast(
            '0mdXNlkwnjX304uZPpbJ', event.me.broadcasting, event.me);
        _addMarker(event.me.broadcasting, event);
      }),
      body: GoogleMap(
          initialCameraPosition: CameraPosition(
              target: LatLng(toronto.latitude, toronto.longitude), zoom: 12),
          onMapCreated: (GoogleMapController controller) async {
            googleMapController = controller;
            myPosition = await Geolocator.getCurrentPosition();
            googleMapController
                .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                    target: LatLng(
                      myPosition.latitude,
                      myPosition.longitude,
                    ),
                    zoom: 15)));
          },
          markers: test ? _markers : _m2),
    );
  }

  toggleTest() {
    print('hello');
    // setState(() {
    //   test = !test;
    // });
  }

  _addMarker(bool meBroadcasting, EventModel event) {
    _markers = {};
    var x = test
        ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
        : BitmapDescriptor.defaultMarker;
    _markers.add(
      Marker(
          markerId: MarkerId('my position 2'),
          infoWindow: InfoWindow(title: 'helo'),
          icon: x,
          onTap: () {
            setState(() {
              test = !test;
            });
            print('test $test');
            print(event.me.broadcasting);
            FirestoreService()
                .toggleMyBroadcast('0mdXNlkwnjX304uZPpbJ', test, event.me);
          },
          position: LatLng(myPosition.latitude, myPosition.longitude)),
    );
  }

  // _moveToMyPosition() async {
  //   myPosition = await Geolocator.getCurrentPosition();
  //   googleMapController
  //       .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //           target: LatLng(
  //             myPosition.latitude,
  //             myPosition.longitude,
  //           ),
  //           zoom: 15)));
  //   _dropMarker();
  // }

  // _dropMarker() {
  //   // var event = Provider.of<EventModel>(context);
  //   // print('debug');
  //   // print(event.me.uid);
  //   _markers.add(
  //     Marker(
  //         markerId: MarkerId('my position'),
  //         infoWindow: InfoWindow(title: 'helo'),
  //         icon:
  //             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  //         onTap: () {
  //           print('i can be tapped');
  //         },
  //         position: LatLng(myPosition.latitude, myPosition.longitude)),
  //   );
  //   setState(() {
  //     print('dropping marker');
  //   });
  // }
}
