import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:architectured/views/google_maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:architectured/models/chat_model.dart';
import 'package:architectured/models/event_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/firestore_service.dart';
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
  var mapMode = false;
  final _panelController = PanelController();

  void openChat() {
    _panelController.open();
  }

  @override
  Widget build(BuildContext context) {
    return friend.uid == null
        ? Scaffold(
            appBar: AppBar(
              title: Text('welcome to chatsdev v1.0'),
              elevation: 0,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'since this is still alphe, data structures change on the fly. That means chats may be deleted on updates. if your profile picture isnt showing up CLICK THIS BUTTON. dont add anyone if your profile picture isnt working. if you want a feature to be developed, poll it here '),
                )),
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
            // not sure why we're returning false
            onWillPop: () async {
              if (_panelController.isPanelClosed) {
                _panelController.open();
                return false;
              }
              final result = await Navigator.pushNamed(context, '/friends');
              setState(() {
                friend = result as UserModel;
              });
              return false;
            },
            child: StreamBuilder<EventModel>(
                stream: _firestore.events(friend.chatsID!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var eventData = snapshot.data;
                    return Theme(
                      data: eventData!.me.broadcasting
                          ? ThemeData.from(
                              colorScheme: ColorScheme.fromSwatch(
                                  primarySwatch: Colors.lightGreen))
                          : Theme.of(context),
                      child: Builder(
                        builder: (context) => Scaffold(
                            appBar: mapMode
                                ? AppBar(
                                    elevation: 0,
                                    leading: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            Icon(
                                              Icons.chevron_left,
                                            ),
                                            Positioned(
                                              top: 16,
                                              left: 4,
                                              child: Icon(
                                                Icons.lock,
                                                size: 7,
                                              ),
                                            )
                                          ],
                                        ),
                                        Flexible(
                                          child: PopupMenuButton(
                                            child: eventData!
                                                    .friend.broadcasting
                                                ? CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor:
                                                        Colors.green,
                                                    child: CircleAvatar(
                                                        radius: 16,
                                                        backgroundImage:
                                                            NetworkImage(friend
                                                                .avatarUrl!)))
                                                : CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            friend.avatarUrl!)),
                                            itemBuilder: ((context) => [
                                                  PopupMenuItem(
                                                      child: Text(
                                                        'onClick, map animates to friends position',
                                                      ),
                                                      onTap: () {}),
                                                ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          friend.displayName!,
                                        )
                                      ],
                                    ),
                                    actions: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                side: BorderSide(
                                                    width: 1.5,
                                                    style: BorderStyle.solid,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .inversePrimary),
                                              ),
                                              primary:
                                                  eventData.placeName == null
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : Colors.purple.shade300),
                                          child: Text(
                                            'close map',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .inversePrimary),
                                          ),
                                          onPressed: () {
                                            _panelController.open();
                                            globalKey.currentState!
                                                .closeSearch();
                                          },
                                        ),
                                      ),
                                      PopupMenuButton(
                                        itemBuilder: ((context) => [
                                              PopupMenuItem(
                                                  child: eventData!
                                                          .me.broadcasting
                                                      ? Text(
                                                          'stop sharing my location',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        )
                                                      : Text(
                                                          'DBG: share location'),
                                                  onTap: () {
                                                    _firestore
                                                        .toggleMyBroadcast(
                                                            friend.chatsID!,
                                                            eventData.me
                                                                .broadcasting,
                                                            eventData.me);
                                                  }),
                                              PopupMenuItem(
                                                child: Text('search map'),
                                                onTap: () {
                                                  globalKey.currentState!
                                                      .toggleShowSearch();
                                                },
                                              ),
                                            ]),
                                      )
                                    ],
                                  )
                                : AppBar(
                                    title: Text(friend.displayName!),
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.chevron_left,
                                        ),
                                        Flexible(
                                          child: PopupMenuButton(
                                            child: eventData!
                                                    .friend.broadcasting
                                                ? CircleAvatar(
                                                    radius: 22,
                                                    backgroundColor:
                                                        Colors.green,
                                                    child: CircleAvatar(
                                                      radius: 17,
                                                      backgroundImage:
                                                          NetworkImage(friend
                                                              .avatarUrl!),
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            friend.avatarUrl!),
                                                  ),
                                            itemBuilder: ((context) => [
                                                  PopupMenuItem(
                                                      child: Text(
                                                          'only if friend is broadcasting will i see this'))
                                                ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    elevation: 0,
                                    actions: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    side: BorderSide(
                                                        width: 1.5,
                                                        style:
                                                            BorderStyle.solid,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .inversePrimary)),
                                                primary: eventData.placeName ==
                                                        null
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Colors.purple.shade300),
                                            child: Text(
                                              'map',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inversePrimary),
                                            ),
                                            onPressed: () {
                                              _panelController.close();
                                            },
                                          ),
                                        ),
                                        PopupMenuButton(
                                          itemBuilder: ((context) => [
                                                PopupMenuItem(
                                                    child: eventData
                                                            .me.broadcasting
                                                        ? Text(
                                                            'stop sharing location',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          )
                                                        : Text(
                                                            'DBG: share locatoin'),
                                                    onTap: () {
                                                      _firestore
                                                          .toggleMyBroadcast(
                                                              friend.chatsID!,
                                                              eventData.me
                                                                  .broadcasting,
                                                              eventData.me);
                                                    }),
                                              ]),
                                        ),
                                      ]),
                            body: Stack(children: [
                              SlidingUpPanel(
                                  controller: _panelController,
                                  maxHeight: MediaQuery.of(context).size.height,
                                  minHeight:
                                      eventData.placeName == null ? 0 : 40,
                                  onPanelClosed: () {
                                    setState(() {
                                      mapMode = true;
                                    });
                                  },
                                  onPanelOpened: () {
                                    setState(() {
                                      mapMode = false;
                                    });
                                  },
                                  defaultPanelState: PanelState.OPEN,
                                  body: GoogleMaps(
                                    key: globalKey,
                                    friend: friend,
                                    openChat: openChat,
                                  ),
                                  panel: Column(
                                    children: [
                                      eventData.placeName == null
                                          ? Container()
                                          : Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              padding: const EdgeInsets.all(12),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    color: Colors.purple,
                                                    size: 15,
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    eventData.placeName!,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .inversePrimary,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    '(${eventData.address!.substring(0, 20)})',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .inversePrimary,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  IconButton(
                                                    constraints:
                                                        BoxConstraints(),
                                                    padding: EdgeInsets.zero,
                                                    onPressed: () {
                                                      _firestore.deleteEvent(
                                                          friend.chatsID!);
                                                    },
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .inversePrimary,
                                                    ),
                                                    iconSize: 16,
                                                  )
                                                ],
                                              ),
                                            ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      StreamBuilder<List<ChatModel>>(
                                        stream: _firestore.getChats(friend),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            var data = snapshot.data;
                                            return Expanded(
                                              child: ListView.builder(
                                                  reverse: false,
                                                  itemCount: data!.length,
                                                  itemBuilder:
                                                      ((context, index) {
                                                    return Row(
                                                      mainAxisAlignment: data[
                                                                      index]
                                                                  .uid ==
                                                              _auth.me.uid
                                                          ? MainAxisAlignment
                                                              .end
                                                          : MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        2),
                                                            child: Material(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              color: data[index]
                                                                          .uid ==
                                                                      _auth.me
                                                                          .uid
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                      .withOpacity(
                                                                          0.7)
                                                                  : Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                      .withOpacity(
                                                                          0.8),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Text(
                                                                  data[index]
                                                                      .text,
                                                                  style: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .inversePrimary),
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
                                  )),
                              mapMode
                                  ? Container()
                                  : Positioned(
                                      bottom: 3,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 70,
                                        padding: EdgeInsets.all(9),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                  onChanged: (val) {
                                                    message = val;
                                                  },
                                                  cursorWidth: 8,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.0),
                                                        borderSide:
                                                            BorderSide.none),
                                                    hintText:
                                                        '    send a message',
                                                  ),
                                                  controller: _controller),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  _firestore.sendMessage(
                                                      message,
                                                      friend.chatsID!.id);
                                                  _controller.clear();
                                                },
                                                child: Icon(
                                                  Icons.chat,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                            ])),
                      ),
                    );
                  }
                  return CircularProgressIndicator();
                }),
          );
  }

  Future<Uint8List> getBytesFromAsset(path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
