// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMaps extends StatefulWidget {
  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  late BitmapDescriptor customIcon;
  // LatLng position = LatLng(43.69602, -79.797692);

  static var _marker = Marker(
    markerId: MarkerId('anoops marker'),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(43.69602, -79.797692),
  );

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/karoake.jpg')
        .then((value) => customIcon = value);
  }

  // createMarkers() {
  //   _markers.add(
  //     Marker(
  //       markerId: MarkerId('test'),
  //       position: position,
  //       icon: BitmapDescriptor.defaultMarker,
  //     ),
  //   );
  // }

  final Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _brampton = CameraPosition(
    target: LatLng(43.69602, -79.797692),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        markers: {_marker},
        initialCameraPosition: _brampton,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
