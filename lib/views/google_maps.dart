// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMaps extends StatefulWidget {
  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  late GoogleMapController googleMapController;
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () async {
        Position position = await _determinePosition();
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 14)));

        final Uint8List markerIcon =
            await getBytesFromAsset('assets/pp1.jpeg', 100);

        _markers.add(Marker(
            icon: BitmapDescriptor.fromBytes(markerIcon),
            markerId: MarkerId('some id'),
            position: LatLng(position.latitude, position.longitude)));
        setState(() {
          print('is there another way to reload state?');
        });
      }),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: _markers,
        initialCameraPosition:
            CameraPosition(target: LatLng(43, -79), zoom: 15),
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
      ),
    );
  }

  Future<Uint8List> getBytesFromAsset(path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('location service not enabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('locatoin permisison denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('denied forver');
    }

    Position position = await Geolocator.getCurrentPosition();
    return position;
  }
}
