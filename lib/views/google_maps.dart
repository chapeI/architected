// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:architectured/bloc/application_bloc.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

GlobalKey<_GoogleMapsState> globalKey = GlobalKey();

class GoogleMaps extends StatefulWidget {
  UserModel friend;
  final Function openChat;

  GoogleMaps({required Key key, required this.friend, required this.openChat})
      : super(key: key);
  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  late GoogleMapController googleMapController;
  Set<Marker> _markers = {};
  final _searchController = TextEditingController();
  var _searchValue;
  bool _showCard = false;
  Map<String, dynamic> result = {};
  late var placeName;
  late var address;
  late var lat;
  late var lng;
  bool showSearch = false;

  void toggleShowSearch() {
    setState(() {
      showSearch = !showSearch;
    });
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
      appBar: showSearch
          ? AppBar(
              toolbarHeight: 30,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
              elevation: 0,
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  onChanged: (val) {
                    _searchValue = val;
                  },
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                      hintText: '   ${widget.friend.uid}',
                      hintStyle: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).primaryColor.withOpacity(1))),
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () async {
                      result = await LocationService().getPlace(_searchValue);
                      lat = result['geometry']['location']['lat'];
                      lng = result['geometry']['location']['lng'];
                      address = result['formatted_address'];
                      placeName = result['name'];
                      _goToPlace(lat, lng);
                      _markers.add(Marker(
                          markerId: MarkerId('yolo'),
                          position: LatLng(lat, lng)));
                      _searchController.text = '';
                      setState(() {
                        _showCard = true;
                      });
                    },
                    child: Icon(
                      Icons.search,
                      size: 14,
                    ))
              ],
            )
          : null,
      body: Stack(children: [
        GoogleMap(
          markers: _markers,
          initialCameraPosition:
              CameraPosition(target: LatLng(43.723598, -79.598046), zoom: 15),
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
          },
        ),
        _showCard
            ? Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                margin: EdgeInsets.all(25),
                child: ListTile(
                  contentPadding: EdgeInsets.all(9),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VerticalDivider(thickness: 2),
                      IconButton(
                          icon: Icon(
                            Icons.add,
                          ),
                          onPressed: () {
                            FirestoreService().addLocation(
                                widget.friend.chatsID!,
                                LatLng(lat, lng),
                                placeName,
                                address);
                            setState(() {
                              _showCard = false;
                            });
                            widget.openChat();
                          }),
                    ],
                  ),
                  title: Text(placeName),
                  subtitle: Text(address),
                ))
            : Container(),
        if (applicationBloc.searchResults != null &&
            applicationBloc.searchResults!.isNotEmpty)
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                backgroundBlendMode: ui.BlendMode.darken),
          ),
        if (applicationBloc.searchResults != null &&
            applicationBloc.searchResults!.isNotEmpty)
          Container(
            height: 300,
            child: ListView.builder(
                itemCount: applicationBloc.searchResults!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      applicationBloc.searchResults![index].desc,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }),
          )
      ]),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 140),
        child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.add),
            onPressed: () async {
              Position position = await _determineMyPosition();

              googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(position.latitude, position.longitude),
                      zoom: 14)));

              var myBitmap =
                  await userImageMarker('assets/pp1.jpeg', title: 'me');
              var myBitmap2 =
                  await userImageMarker('assets/pp2.jpeg', title: 'godson');

              _markers.add(Marker(
                  icon: myBitmap,
                  markerId: MarkerId('some id'),
                  position: LatLng(position.latitude, position.longitude)));

              _markers.add(Marker(
                  icon: myBitmap2,
                  markerId: MarkerId('anotehr id'),
                  position: LatLng(
                      position.latitude - 0.01, position.longitude - 0.01)));

              _markers.add(Marker(
                  icon: BitmapDescriptor.defaultMarkerWithHue(270),
                  markerId: MarkerId('another id'),
                  position: LatLng(43.723598, -79.598046)));

              setState(() {
                print('is there another way to reload state?');
              });
            }),
      ),
    );
  }

  Future<void> _goToPlace(lat, lng) async {
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 20)));
  }

  // Future<Uint8List> getBytesFromAsset(path, int width) async {
  //   ByteData data = await rootBundle.load(path);
  //   ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
  //       targetWidth: width);
  //   ui.FrameInfo fi = await codec.getNextFrame();
  //   return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
  //       .buffer
  //       .asUint8List();
  // }

  Future<BitmapDescriptor> userImageMarker(imageFile,
      {int size = 150,
      required title,
      // bool addBorder = false,
      Color borderColor = Colors.green,
      double borderSize = 15,
      Color titleColor = Colors.black,
      Color titleBackgroundColor = Colors.green}) async {
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

  Future<Position> _determineMyPosition() async {
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
