import 'package:architectured/models/event_model.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/services/user_controller.dart';
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
  Widget build(BuildContext context) {
    var event = Provider.of<EventModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(event.lastMessage),
        leading: CircleAvatar(
            backgroundImage:
                NetworkImage(UserController().currentUser.avatarUrl!)),
      ),
      body: GoogleMap(
        zoomControlsEnabled: false,
        initialCameraPosition:
            CameraPosition(target: LatLng(43.6426, -79.3871), zoom: 12),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) async {},
      ),
    );
  }
}
