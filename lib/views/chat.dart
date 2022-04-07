// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
import 'dart:ffi';

import 'package:architectured/models/chat_model.dart';
import 'package:architectured/models/event_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/views/google_maps.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Chat extends StatefulWidget {
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _focusNode = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      // keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      // keyboardBarColor: Colors.red[200],
      // nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _focusNode,
          toolbarButtons: [
            //button 1
            (node) {
              return GestureDetector(
                  onTap: () => node.unfocus(),
                  child: Container(
                    color: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(
                      child: Text(
                        "CLOSE",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ));
            },
            //button 2
            (node) {
              return GestureDetector(
                onTap: () {
                  _firestore.sendMessage(message, friend.chatsID!.id);
                  _controller.clear();
                  return node.unfocus();
                },
                child: Container(
                  color: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  child: Center(
                    child: Text(
                      "SEND",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ],
        ),
      ],
    );
  }

  var friend = UserModel(email: 'INIT', uid: null);
  final _firestore = FirestoreService();
  final _auth = AuthService();
  final _controller = TextEditingController();
  final _eventController = TextEditingController();
  String message = '';
  String eventName = '';
  var panelOpen = true;

  @override
  Widget build(BuildContext context) {
    return friend.uid == null
        ? Scaffold(
            appBar: AppBar(title: Text('welcome to chatsdev v1.0')),
            body: Center(
              child: OutlinedButton(
                  onPressed: () async {
                    final result =
                        await Navigator.pushNamed(context, '/friends');
                    setState(() {
                      friend = result as UserModel;
                    });
                  },
                  child: Text('LAUNCH')),
            ),
          )
        : Scaffold(
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                    heroTag: 'goBack',
                    child: Icon(Icons.arrow_back),
                    onPressed: () async {
                      final result =
                          await Navigator.pushNamed(context, '/friends');
                      setState(() {
                        friend = result as UserModel;
                      });
                    }),
                SizedBox(
                  width: 10,
                ),
                FloatingActionButton(
                  heroTag: 'chat',
                  onPressed: () {
                    _focusNode.requestFocus();
                  },
                  child: Icon(Icons.message),
                ),
              ],
            ),
            appBar: AppBar(
                elevation: 0,
                flexibleSpace: SafeArea(
                    child: KeyboardActions(
                  config: _buildConfig(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: TextField(
                            controller: _controller,
                            onChanged: (val) {
                              message = val;
                            },
                            focusNode: _focusNode,
                            cursorColor: Colors.white,
                            cursorWidth: 8,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                hintStyle: TextStyle(color: Colors.blue[200]),
                                hintText: panelOpen
                                    ? '   happy chatting!'
                                    : '   map isnt not working yet'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))),
            body: SlidingUpPanel(
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
                minHeight: 65,
                body: GoogleMaps(),
                panel: StreamBuilder<String?>(
                    stream: _firestore.events(friend.chatsID!),
                    builder: (context, snapshot) {
                      String? event = snapshot.data;
                      print('event');
                      print(
                          event ?? 'caught if firestore field not set to null');
                      // print(event!.name);
                      // print(event.time ?? 'actually receing null');
                      return Column(
                        children: [
                          ListTile(
                            title: event == null
                                ? Text(friend.email!.substring(4))
                                : Text('LETS ${event}'),

                            subtitle: event == null
                                ? null
                                : Text(friend.email!.substring(4)),
                            // title: Text(friend.email!.substring(4)),
                            trailing: IconButton(
                              icon: event == null
                                  ? Icon(Icons.add)
                                  : Icon(Icons.edit),
                              onPressed: () {
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SingleChildScrollView(
                                          child: Container(
                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom),
                                              child: Column(
                                                children: [
                                                  AppBar(
                                                    automaticallyImplyLeading:
                                                        false,
                                                    leading: IconButton(
                                                      icon: Icon(Icons
                                                          .add_photo_alternate),
                                                      onPressed: null,
                                                    ),
                                                    // title: Text('edit event'),
                                                    actions: [
                                                      IconButton(
                                                          onPressed: null,
                                                          icon: Icon(Icons
                                                              .add_location_alt)),
                                                      IconButton(
                                                          onPressed: () {
                                                            _firestore.addEventTime(
                                                                friend.chatsID!,
                                                                'literally anything');
                                                          },
                                                          icon: Icon(
                                                              Icons.more_time)),
                                                      IconButton(
                                                          onPressed: () {
                                                            _firestore.deleteEvent(
                                                                friend
                                                                    .chatsID!);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          icon: Icon(
                                                              Icons.delete))
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextField(
                                                            onChanged: (val) {
                                                              eventName = val;
                                                            },
                                                            controller:
                                                                _eventController,
                                                            decoration: InputDecoration(
                                                                hintText: event ==
                                                                        null
                                                                    ? 'make an event name'
                                                                    : "edit event name: '${event}'"),
                                                          ),
                                                        ),
                                                        IconButton(
                                                            onPressed: () {
                                                              _firestore.addEvent(
                                                                  friend
                                                                      .chatsID!,
                                                                  eventName);
                                                              _eventController
                                                                  .clear();
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            icon: Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.blue,
                                                            ))
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )));
                                    });
                              },
                            ),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(friend.avatarUrl!),
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
                                                    horizontal: 10,
                                                    vertical: 2),
                                                // color: Colors.blue[100],
                                                child: Material(
                                                  color: Colors.blue,
                                                  borderRadius: data[index]
                                                              .uid ==
                                                          _auth.me.uid
                                                      ? BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  5),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  1),
                                                          topLeft:
                                                              Radius.circular(
                                                                  5),
                                                          topRight:
                                                              Radius.circular(
                                                                  5),
                                                        )
                                                      : BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  1),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  5),
                                                          topLeft:
                                                              Radius.circular(
                                                                  5),
                                                          topRight:
                                                              Radius.circular(
                                                                  5),
                                                        ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
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
                              return LinearProgressIndicator();
                            },
                          ),
                        ],
                      );
                    })),
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
