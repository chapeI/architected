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

        var myBitmap = await userImageMarkers('assets/pp1.jpeg');

        _markers.add(Marker(
            icon: myBitmap,
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

  Future<BitmapDescriptor> userImageMarkers(
    imageFile, {
    int size = 150,
    // bool addBorder = false,
    Color borderColor = Colors.lightGreen,
    double borderSize = 15,
    Color titleColor = Colors.white,
    Color titleBackgroundColor = Colors.green,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color;
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final radius = size / 2;

    // make canvas clip path to prevent image drawing over circle
    final Path clipPath = Path();

    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Radius.circular(150)));
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
        Radius.circular(150)));
    canvas.clipPath(clipPath);

    // paintImage
    // final imageUint8List = await imageFile.readAsBytes();
    ByteData dataDebug = await rootBundle.load(imageFile);
    final codec = await ui.instantiateImageCodec(dataDebug.buffer.asUint8List(),
        targetWidth: 150);
    final imageFI = await codec.getNextFrame();

    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        image: imageFI.image);

    paint.color = borderColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = borderSize;
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    String title = 'godwin';

    paint.color = titleBackgroundColor;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
        ui.RRect.fromRectAndRadius(
            Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
            Radius.circular(100)),
        paint);

    textPainter.text = TextSpan(
        text: title,
        style: TextStyle(
            fontSize: radius / 2.5,
            fontWeight: FontWeight.bold,
            color: titleColor));

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(radius - textPainter.width / 2,
            size * 9.5 / 10 - textPainter.height / 2));

    // convert canvas as PNG bytes
    final _image = await pictureRecorder
        .endRecording()
        .toImage(size, (size * 1.1).toInt());
    final data = await _image.toByteData(format: ui.ImageByteFormat.png);

    // convert PNG bytes as BitmapDescriptor
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
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
