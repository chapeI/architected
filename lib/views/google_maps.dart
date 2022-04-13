// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'package:flutter/material.dart';
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
        _markers.add(Marker(
            markerId: MarkerId('some id'),
            position: LatLng(position.latitude, position.longitude)));
        setState(() {
          print('really? theres no otherway to reload state?');
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
