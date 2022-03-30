// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:architectured/models/user_model.dart';
import 'package:architectured/views/chat_view.dart';
import 'package:flutter/material.dart';

class SlidingChat extends StatefulWidget {
  @override
  State<SlidingChat> createState() => _SlidingChatState();
}

class _SlidingChatState extends State<SlidingChat> {
  UserModel friend = UserModel(email: 'INIT', uid: null);
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
            appBar: AppBar(
              title: Text(friend.email!),
              leading: ElevatedButton(
                child: Icon(Icons.arrow_back),
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/friends');
                  setState(() {
                    friend = result as UserModel;
                  });
                },
              ),
              bottom: AppBar(
                title: Text('BubbleTea'),
                actions: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.location_on)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.check)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.close)),
                ],
              ),
            ),
            body: ChatView(
              friend: friend,
            ),
          );
  }
}
