// ignore_for_file: prefer_const_constructors
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // BitmapDescriptor.fromAssetImage(
    //         ImageConfiguration(size: Size(1, 1)), 'assets/pp1.jpeg')
    //     .then((icon) => customIcon = icon);

    setMarker();
    super.initState();
  }

  void setMarker() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/pp1.jpeg', 100);

    Marker marker = Marker(
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: LatLng(43.69602, -79.797692),
        markerId: MarkerId('markerId'));

    _markers.add(marker);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  final Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _brampton = CameraPosition(
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
        },
      ),
    );
  }
}
