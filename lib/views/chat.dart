// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:architectured/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Chat extends StatefulWidget {
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  UserModel friend = UserModel(email: 'INIT', uid: 'jskadjflk');
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
            body: SafeArea(
              child: SlidingUpPanel(
                  // FOCUS HERE
                  maxHeight: MediaQuery.of(context).size.height,
                  body: Center(child: Text('Maps')),

                  // HEADER (COLLAPSED AND PANEL)
                  header: Text('jackob'),

                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: TextField(
                  //         onChanged: ((value) {
                  //           message = value;
                  //         }),
                  //       ),
                  //     ),
                  //     TextButton(onPressed: null, child: Text('search'))
                  //   ],
                  // ),
                  // COLLAPSED (EVENT SUMMARY)
                  collapsed: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Divider(
                        color: Colors.red,
                      ),
                    ],
                  ),

                  // PANEL (CHAT)
                  panel: Column(
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      Divider(
                        color: Colors.blue,
                      ),
                      Text('top of panel INTERFERENCE'),
                      Row(
                        children: [
                          Expanded(child: TextField(
                            onChanged: ((value) {
                              message = value;
                            }),
                          )),
                          TextButton(onPressed: null, child: Text('send'))
                        ],
                      )
                    ],
                  )),
            ),
          );
  }
}

BoxDecoration myBoxDecoration() {
  return BoxDecoration(border: Border.all());
}
