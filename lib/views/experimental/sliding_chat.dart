// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:architectured/main.dart';
import 'package:architectured/views/experimental/map/g_map.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SlidingChat extends StatefulWidget {
  @override
  State<SlidingChat> createState() => _SlidingChatState();
}

class _SlidingChatState extends State<SlidingChat> {
  var friendUid;
  @override
  Widget build(BuildContext context) {
    return friendUid == null
        ? Scaffold(
            appBar: AppBar(title: Text('pick a chat')),
            body: Column(
              children: [
                Text(
                    'welcome to chatsdev, a chat application thats currently in development, actually will always be in development'),
                Text('latest updates include')
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/friends');
                setState(() {
                  friendUid = result;
                });
              },
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(friendUid ?? 'pick another chat'),
              leading: ElevatedButton(
                child: Icon(Icons.arrow_back),
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/friends');
                  setState(() {
                    friendUid = result;
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
