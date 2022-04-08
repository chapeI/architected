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
  Set<Marker> _markers = {};

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(1, 1)), 'assets/pp1.jpeg')
        .then((icon) => customIcon = icon);
    super.initState();
  }

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
        markers: _markers,
        initialCameraPosition: _brampton,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);

          setState(() {
            _markers.add(Marker(
              markerId: MarkerId('test'),
              position: LatLng(43.69602, -79.797692),
              icon: customIcon,
            ));
          });
        },
      ),
    );
  }
}
