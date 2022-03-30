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
                  maxHeight: MediaQuery.of(context).size.height,
                  body: Center(child: Text('Maps')),
                  panel: Column(
                    children: [
                      Container(
                        height: 100,
                        decoration: myBoxDecoration(),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: myBoxDecoration(),
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: null,
                                        icon: Icon(Icons.location_on)),
                                    Text('basketball')
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: null,
                                      icon: Icon(Icons.arrow_back)),
                                  CircleAvatar(),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Jos')
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 200,
                        decoration: myBoxDecoration(),
                        child: Center(
                          child: Text('chat messages'),
                        ),
                      ),
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
