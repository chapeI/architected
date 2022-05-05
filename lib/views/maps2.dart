// ignore_for_file: unused_local_variable

import 'package:architectured/models/event_model.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/services/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

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
            const CameraPosition(target: LatLng(43.6426, -79.3871), zoom: 12),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) async {},
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        var myBitmap = await circleMarker(
            UserController().currentUser.avatarUrl,
            color: Colors.blue,
            title: 'hi');
        setState(() {
          _markers.add(Marker(
              markerId: MarkerId('test'),
              icon: myBitmap,
              position: LatLng(43.6426, -79.3271)));
        });
      }),
    );
  }

  circleMarker(String? myAvatarUrl,
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
        text: 'me',
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
