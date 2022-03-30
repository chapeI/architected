// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:architectured/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Chat extends StatefulWidget {
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  UserModel friend = UserModel(email: 'INIT', uid: null);
  String message = '';
  @override
  Widget build(BuildContext context) {
    return friend.uid == null
        ? Scaffold(
            appBar: AppBar(title: Text('pick a chat')),
            body: Column(
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                Text(
                    'welcome to chatsdev, a chat application thats currently in development, actually will always be in development'),
                Text('recent updates: '),
                ElevatedButton(
                    onPressed: () async {
                      final result =
                          await Navigator.pushNamed(context, '/friends');
                      setState(() {
                        friend = result as UserModel;
                        print('quar: ${friend.uid}');
                      });
                    },
                    child: Text('go to friends'))
              ],
            ),
          )
        : Scaffold(
            body: SlidingUpPanel(
                body: Center(child: Text('Maps')),
                panel: Column(
                  children: [
                    Text('chats'),
                    Container(
                      child: Expanded(child: TextField(
                        onChanged: ((value) {
                          message = value;
                        }),
                      )),
                    )
                  ],
                )),
            // appBar: AppBar(
            //   title: Text(friend.email!),
            //   leading: ElevatedButton(
            //     child: Icon(Icons.arrow_back),
            //     onPressed: () async {
            //       final result = await Navigator.pushNamed(context, '/friends');
            //       setState(() {
            //         friend = result as UserModel;
            //       });
            //     },
            //   ),
            //   bottom: AppBar(
            //     title: Text('BubbleTea'),
            //     actions: [
            //       IconButton(onPressed: () {}, icon: Icon(Icons.location_on)),
            //       IconButton(onPressed: () {}, icon: Icon(Icons.check)),
            //       IconButton(onPressed: () {}, icon: Icon(Icons.close)),
            //     ],
            //   ),
            // ),
            // body: ChatView(
            //   friend: friend,
            // ),
          );
  }
}
