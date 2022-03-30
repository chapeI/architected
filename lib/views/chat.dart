// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
import 'package:architectured/models/user_model.dart';
import 'package:architectured/views/google_maps.dart';
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
                  minHeight: 100,
                  body: Text('map'),
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
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('basketball '),
                                    Text('6 PM @ '),
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.purple,
                                    ),
                                    Text('Dufferin School'),
                                    Spacer(),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                        )),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            AssetImage('assets/lowry.jpg'),
                                        radius: 10,
                                      ),
                                    )
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
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage:
                                        AssetImage('assets/pp3.jpeg'),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Jos'),
                                  Spacer(),
                                  IconButton(
                                      onPressed: null, icon: Icon(Icons.phone)),
                                  IconButton(
                                      onPressed: null,
                                      icon: Icon(Icons.more_vert))
                                ],
                              ),
                            ),
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
                    ],
                  )),
            ),
            bottomNavigationBar: Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 5, bottom: 5.0),
                  child: TextField(
                    onChanged: ((value) {
                      message = value;
                    }),
                  ),
                )),
                TextButton(
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Row(
                        children: [
                          Icon(Icons.search),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.message)
                        ],
                      ),
                    ))
              ],
            ));
  }
}

BoxDecoration myBoxDecoration() {
  return BoxDecoration(border: Border.all());
}
