// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
import 'package:architectured/models/chat_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/views/google_maps.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Chat extends StatefulWidget {
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  var friend = UserModel(email: 'INIT', uid: null);
  final _firestore = FirestoreService();
  final _auth = AuthService();
  final _constroller = TextEditingController();
  String message = '';
  var panelOpen = true;
  @override
  Widget build(BuildContext context) {
    return friend.uid == null
        ? Scaffold(
            appBar: AppBar(title: Text('pick a chat')),
            body: Column(
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                Text(
                    'welcome to chatsdev, a chat app in development, will always be in development. we are always looking to roll out new features'),
                Text('recent updates: chat works, sign up works, '),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final result =
                          await Navigator.pushNamed(context, '/friends');
                      setState(() {
                        friend = result as UserModel;
                      });
                    },
                    child: Text('go to my chats'))
              ],
            ),
          )
        : Scaffold(
            body: SafeArea(
              child: SlidingUpPanel(
                  onPanelClosed: () {
                    setState(() {
                      panelOpen = false;
                    });
                  },
                  onPanelOpened: () {
                    setState(() {
                      panelOpen = true;
                    });
                  },
                  defaultPanelState: PanelState.OPEN,
                  maxHeight: MediaQuery.of(context).size.height,
                  body: GoogleMaps(),
                  panel: Column(
                    children: [
                      Container(
                        height: 100,
                        decoration: myBoxDecoration(),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
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
                                    CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/lowry.jpg'),
                                      radius: 10,
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.expand_more))
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        final result =
                                            await Navigator.pushNamed(
                                                context, '/friends');
                                        setState(() {
                                          friend = result as UserModel;
                                        });
                                      },
                                      icon: Icon(Icons.arrow_back)),
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage:
                                        NetworkImage(friend.avatarUrl!),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(friend.email!),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      StreamBuilder<List<ChatModel>>(
                        stream: _firestore.getChats(friend),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data;
                            return Expanded(
                              child: ListView.builder(
                                  // reverse: true,
                                  itemCount: data!.length,
                                  itemBuilder: ((context, index) {
                                    return Row(
                                      mainAxisAlignment:
                                          data[index].uid == _auth.me.uid
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          // color: Colors.blue[100],
                                          child: Text(data[index].text),
                                        )
                                      ],
                                    );
                                  })),
                            );
                          }
                          return Text('null snapshot, check shape');
                        },
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
                    controller: _constroller,
                    onChanged: ((value) {
                      message = value;
                    }),
                  ),
                )),
                TextButton(
                    onPressed: () {},
                    child: panelOpen
                        ? IconButton(
                            onPressed: () {
                              _firestore.sendMessage(
                                  message, friend.chatsID!.id);
                              _constroller.clear();
                            },
                            icon: Icon(Icons.message))
                        : IconButton(
                            onPressed: null, icon: Icon(Icons.travel_explore)))
                // child: Row(
                //   children: [
                //     IconButton(onPressed: null, icon: Icon(Icons.search)),
                //     IconButton(
                //         onPressed: () {
                //         },
                //         icon: Icon(Icons.message)),
                //   ],
                // ))
              ],
            ));
  }
}

BoxDecoration myBoxDecoration() {
  return BoxDecoration(
      border: Border(
    top: BorderSide(width: 1.0, color: Colors.lightBlue.shade600),
    bottom: BorderSide(width: 1.0, color: Colors.lightBlue.shade600),
  ));
}
