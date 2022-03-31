import 'package:architectured/views/google_maps.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SandBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SlidingUpPanel(
        minHeight: 20,
        body: GoogleMaps(),
        panel:
            Text('hide panel for now, eventually things need to show up here'),
      )),
    );
  }
}
