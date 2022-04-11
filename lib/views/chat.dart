// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
import 'dart:ffi';
import 'dart:ui';

import 'package:architectured/models/chat_model.dart';
import 'package:architectured/models/event_model.dart';
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
  final _eventController = TextEditingController();
  String message = '';
  String eventName = '';
  var panelOpen = true;

  @override
  Widget build(BuildContext context) {
    return friend.uid == null
        ? Scaffold(
            appBar: AppBar(title: Text('welcome to chatsdev v1.0')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(child: Text('this launch screen will be removed soon')),
                OutlinedButton(
                    onPressed: () async {
                      final result =
                          await Navigator.pushNamed(context, '/friends');
                      setState(() {
                        friend = result as UserModel;
                      });
                    },
                    child: Text('LAUNCH')),
              ],
            ),
          )
        : WillPopScope(
            onWillPop: () async {
              final result = await Navigator.pushNamed(context, '/friends');
              setState(() {
                friend = result as UserModel;
              });
              return false;
            },
            child: Scaffold(
              body: SafeArea(
                child: Stack(children: [
                  SlidingUpPanel(
                      maxHeight: MediaQuery.of(context).size.height,
                      minHeight: 120,
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
                      // maxHeight: MediaQuery.of(context).size.height,
                      // minHeight: 65,
                      body: GoogleMaps(),
                      panel: StreamBuilder<EventModel>(
                          stream: _firestore.events(friend.chatsID!),
                          builder: (context, snapshot) {
                            EventModel? eventData = snapshot.data;
                            return Column(
                              children: [
                                ListTile(
                                  title: eventData?.event == null
                                      ? Text(friend.email!.substring(4))
                                      : Row(
                                          children: [
                                            Text(
                                                '${eventData!.event} with ${friend.email!.substring(4)}'),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                              onPressed: () {
                                                showModal(context, eventData);
                                              },
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.grey,
                                                size: 15,
                                              ),
                                            )
                                          ],
                                        ),
                                  trailing: eventData == null
                                      ? IconButton(
                                          icon: Icon(Icons.add),
                                          onPressed: () {
                                            showModal(context, eventData);
                                          },
                                        )
                                      : null,
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(friend.avatarUrl!),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: panelOpen ? 20 : 90,
                                ),
                                StreamBuilder<List<ChatModel>>(
                                  stream: _firestore.getChats(friend),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      var data = snapshot.data;
                                      return Expanded(
                                        child: ListView.builder(
                                            reverse: true,
                                            itemCount: data!.length,
                                            itemBuilder: ((context, index) {
                                              return Row(
                                                mainAxisAlignment: data[index]
                                                            .uid ==
                                                        _auth.me.uid
                                                    ? MainAxisAlignment.end
                                                    : MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 2),
                                                      // color: Colors.blue[100],
                                                      child: Material(
                                                        color: data[index]
                                                                    .uid ==
                                                                _auth.me.uid
                                                            ? Colors.blue[800]
                                                            : Colors.blue[500],
                                                        borderRadius:
                                                            data[index].uid ==
                                                                    _auth.me.uid
                                                                ? BorderRadius
                                                                    .only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            5),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            1),
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            5),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            5),
                                                                  )
                                                                : BorderRadius
                                                                    .only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            1),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            5),
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            5),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            data[index].text,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
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
                                SizedBox(
                                  height: 120,
                                )
                              ],
                            );
                          })),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (val) {
                                  message = val;
                                },
                                cursorColor: Colors.blue[200],
                                cursorWidth: 8,
                                decoration: InputDecoration(
                                    filled: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide.none),
                                    fillColor: Colors.blue[50],
                                    hintText: panelOpen
                                        ? '    send a message'
                                        : '    search map'),
                                controller: _controller,
                              ),
                            ),
                            panelOpen
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _firestore.sendMessage(
                                            message, friend.chatsID!.id);
                                        _controller.clear();
                                      },
                                      child: Icon(Icons.send),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: ElevatedButton(
                                        onPressed: () {},
                                        child: Icon(Icons.search)),
                                  )
                          ],
                        ),
                      ),
                    ),
                  )
                ]),
              ),
            ),
          );
  }

  Future<dynamic> showModal(BuildContext context, EventModel? eventData) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    children: [
                      AppBar(
                        automaticallyImplyLeading: false,
                        leading: IconButton(
                          icon: Icon(Icons.add_photo_alternate),
                          onPressed: null,
                        ),
                        // title: Text('edit event'),
                        actions: [
                          IconButton(
                              onPressed: null,
                              icon: Icon(Icons.add_location_alt)),
                          IconButton(
                              onPressed: null, icon: Icon(Icons.more_time)),
                          IconButton(
                              onPressed: () {
                                _firestore.deleteEvent(friend.chatsID!);
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.delete))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (val) {
                                  eventName = val;
                                },
                                controller: _eventController,
                                decoration: InputDecoration(
                                    hintText: eventData == null
                                        ? 'whats your events name'
                                        : "edit: '${eventData.event}'"),
                              ),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  _firestore.addEvent(
                                      friend.chatsID!, eventName);
                                  _eventController.clear();
                                  Navigator.pop(context);
                                },
                                child: Text('Go!'))
                          ],
                        ),
                      ),
                    ],
                  )));
        });
  }
}

BoxDecoration myBoxDecoration() {
  return BoxDecoration(
      border: Border(
    top: BorderSide(width: 1.0, color: Colors.lightBlue.shade600),
    bottom: BorderSide(width: 1.0, color: Colors.lightBlue.shade600),
  ));
}
