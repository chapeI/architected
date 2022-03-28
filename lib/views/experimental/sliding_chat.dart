// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:architectured/map/g_map.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SlidingChat extends StatefulWidget {
  @override
  State<SlidingChat> createState() => _SlidingChatState();
}

class _SlidingChatState extends State<SlidingChat> {
  var uid;
  @override
  Widget build(BuildContext context) {
    // streamProvider goes here
    return Scaffold(
      appBar: AppBar(
        title: Text(uid == null ? 'go back to chats' : 'chatmap w $uid'),
        leading: ElevatedButton(
          child: Icon(Icons.arrow_back),
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/second');
            setState(() {
              uid = result;
            });
          },
        ),
      ),
      body: SlidingUpPanel(
        panel: Center(child: Text('chat')),
        body: gMap(),
        // needed properties but not imp
        maxHeight: MediaQuery.of(context).size.height,
        // could be useful
        collapsed: Center(
          child: Text('event widget'),
        ),
        header: Text('header'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
      ),
    );
  }
}
