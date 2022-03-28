// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SlidingChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        panel: Center(child: Text('chat')),
        body: Center(child: Text('map')),
        // needed properties but not imp
        maxHeight: MediaQuery.of(context).size.height,
        // could be useful
        collapsed: Center(
          child: Text('event widget'),
        ),
        header: Text('header'),
      ),
    );
  }
}
