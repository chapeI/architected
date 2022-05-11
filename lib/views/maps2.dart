// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:architectured/bloc/application_bloc.dart';
import 'package:architectured/models/event_model.dart';
import 'package:architectured/models/place_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/services/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class Maps2 extends StatefulWidget {
  final UserModel friend;
  const Maps2({Key? key, required this.friend}) : super(key: key);

  @override
  State<Maps2> createState() => _Maps2State();
}

class _Maps2State extends State<Maps2> {
  late GoogleMapController googleMapController;
  late StreamSubscription locationSubscription;
  final searchController = TextEditingController();
  Set<Marker> _markers = {};

  @override
  void initState() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null) {
        _goToPlace(place);
      }
    });
    super.initState();
  }

  @override // this may never be getting called, it always exists in our app
  void dispose() {
    print('DISPOSE CALLED');
    // TODO: implement dispose
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    applicationBloc.dispose();
    locationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    var event = Provider.of<EventModel>(context);
    var color = event.me.broadcasting ? Colors.green : Colors.pink;

    Future<BitmapDescriptor> myCircleAvatar = circleMarker(
        UserController().currentUser.avatarUrl,
        title: 'me',
        color: color);
    Future<BitmapDescriptor> friendCircleAvatar = circleMarker(
        widget.friend.avatarUrl,
        title: widget.friend.displayName,
        color: Colors.green);
    Future<BitmapDescriptor> eventMarker = _setCustomMapPin();
    Future<Position> myPosition = _determineMyLocation();

    return FutureBuilder(
        future: Future.wait(
            [myCircleAvatar, friendCircleAvatar, myPosition, eventMarker]),
        builder: (context, AsyncSnapshot<List> snapshot) {
          _markers = {};
          Position myPosn = snapshot.data![2];
          _markers.add(
            Marker(
                markerId: MarkerId('me'),
                icon: snapshot.data![0],
                position: LatLng(myPosn.latitude, myPosn.longitude),
                onTap: () {
                  FirestoreService().toggleMyBroadcast(
                      widget.friend.chatsID!.id,
                      event.me.broadcasting,
                      event.me,
                      LatLng(myPosn.latitude, myPosn.longitude));
                  setState(() {
                    print('if error, setstate to red');
                  });
                }),
          );

          if (event.friend.broadcasting) {
            _markers.add(Marker(
              markerId: MarkerId('friend'),
              position: LatLng(event.friend.location.latitude,
                  event.friend.location.longitude),
              icon: snapshot.data![1],
            ));
          } else {
            _markers =
                _markers.where((m) => m.markerId != MarkerId('friend')).toSet();
          }

          if (event.placeName != null) {
            _setCustomMapPin();
            _markers.add(Marker(
                markerId: MarkerId('event'),
                icon: snapshot.data![3],
                position: LatLng(
                    event.location!.latitude, event.location!.longitude)));
          }

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: TextFormField(
                controller: searchController,
                decoration:
                    InputDecoration(hintText: 'click here to search map'),
                onChanged: (val) {
                  applicationBloc.searchPlaces(
                      val, LatLng(myPosn.latitude, myPosn.longitude));
                },
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      searchController.clear();
                      applicationBloc.searchPlaces(
                          '', LatLng(myPosn.latitude, myPosn.longitude));
                    },
                    child: Icon(Icons.cancel))
              ],
            ),
            body: Stack(
              children: [
                GoogleMap(
                  zoomControlsEnabled: false,
                  initialCameraPosition: const CameraPosition(
                      target: LatLng(43.6426, -79.3871), zoom: 12),
                  markers: _markers,
                  rotateGesturesEnabled: false,
                  onMapCreated: (GoogleMapController controller) async {
                    googleMapController = controller;
                    // googleMapController.setMapStyle(Utils.mapStyles);
                    _animateCamera(myPosn.latitude, myPosn.longitude);
                  },
                ),
                if (applicationBloc.searchResults != null &&
                    applicationBloc.searchResults!.isNotEmpty)
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        backgroundBlendMode: BlendMode.darken),
                  ),
                if (applicationBloc.searchResults != null &&
                    applicationBloc.searchResults!.isNotEmpty)
                  Container(
                      height: 300,
                      child: ListView.builder(
                          itemCount: applicationBloc.searchResults!.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                applicationBloc.setSelectedLocation(
                                    applicationBloc
                                        .searchResults![index].placeId);
                                searchController.clear();
                              },
                              title: Text(
                                applicationBloc.searchResults![index].desc,
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            );
                          }))
              ],
            ),
          );
        });
  }

  Future<void> _goToPlace(PlaceModel place) async {
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            zoom: 14,
            target: LatLng(place.geometryModel.locationModel.lat,
                place.geometryModel.locationModel.lng))));
  }

  Future<BitmapDescriptor> _setCustomMapPin() async {
    return BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/mapMarker.png');
  }

  _animateCamera(lat, lng) {
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(zoom: 14, target: LatLng(lat, lng))));
  }

  Future<Position> _determineMyLocation() async {
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

  Future<BitmapDescriptor> circleMarker(String? myAvatarUrl,
      {required title, required Color color}) async {
    int size = 120; // change 150
    var borderColor = color;
    const titleColor = Colors.black;
    double borderSize = 20;
    var titleBackgroundColor = color;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color;
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final radius = size / 2;
    final clipPath = Path();

    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        const Radius.circular(150)));
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
        const Radius.circular(150)));
    canvas.clipPath(clipPath);

    http.Response response = await http.get(Uri.parse(myAvatarUrl!));
    final codec = await ui.instantiateImageCodec(response.bodyBytes,
        targetWidth: 150); // change 150
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
}

class Utils {
  static String mapStyles = '''
  [
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
]
  ''';
}
