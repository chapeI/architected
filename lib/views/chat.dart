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
  final _controller = TextEditingController();
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
            appBar: panelOpen
                ? AppBar(
                    elevation: 0,
                    title: TextFormField(
                      onChanged: (val) {
                        message = val;
                      },
                      controller: _controller,
                      cursorColor: Colors.white,
                      cursorWidth: 5,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.blue[200]),
                        hintText: '  send messages from here',
                      ),
                    ),
                    actions: [
                      IconButton(
                          onPressed: () {
                            _firestore.sendMessage(message, friend.chatsID!.id);
                          },
                          icon: Icon(Icons.message))
                    ],
                  )
                : AppBar(
                    elevation: 0,
                    title: TextFormField(
                      onChanged: (val) {
                        message = val;
                      },
                      style: TextStyle(color: Colors.red),
                      controller: _controller,
                      cursorColor: Colors.red,
                      cursorWidth: 1,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.blue[200]),
                          hintText: ' map functionality coming soon'),
                    ),
                    actions: [
                      IconButton(
                          onPressed: () {
                            _controller.clear();
                          },
                          icon: Icon(Icons.search))
                    ],
                  ),
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
                  minHeight: 50,
                  body: GoogleMaps(),
                  panel: Column(
                    children: [
                      Container(
                        height: 50,
                        child: Column(
                          children: [
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
                                  Spacer(),
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
                                                horizontal: 10, vertical: 2),
                                            // color: Colors.blue[100],
                                            child: Material(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  data[index].text,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ))
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
            // bottomNavigationBar:
          );
  }
}

BoxDecoration myBoxDecoration() {
  return BoxDecoration(
      border: Border(
    top: BorderSide(width: 1.0, color: Colors.lightBlue.shade600),
    bottom: BorderSide(width: 1.0, color: Colors.lightBlue.shade600),
  ));
}
