import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:architectured/views/google_maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final _nameEventController = TextEditingController();
  String message = '';
  String eventName = '';
  var panelOpen = true;
  final _panelController = PanelController();
  bool planning = false;
  LatLng? latLng;
  final _searchController = TextEditingController();
  bool _expandedEvent = false;

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
            onWillPop: () async {
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
                    return Scaffold(
                        appBar: panelOpen
                            ? AppBar(
                                title: Text(friend.displayName!),
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 18),
                                  child: PopupMenuButton(
                                    child: eventData!.friend.broadcasting
                                        ? CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Colors.red,
                                            child: CircleAvatar(
                                              radius: 17,
                                              backgroundImage: NetworkImage(
                                                  friend.avatarUrl!),
                                            ),
                                          )
                                        : CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(friend.avatarUrl!),
                                          ),
                                    itemBuilder: ((context) => [
                                          PopupMenuItem(
                                              child: Text(
                                                  'pulls down map then goes to his location, if broadcasting, else request'))
                                        ]),
                                  ),
                                ),
                                elevation: 0,
                                actions: [
                                    VerticalDivider(
                                      thickness: 2,
                                    ),
                                    SizedBox(
                                      width: 14,
                                    ),
                                    PopupMenuButton(
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            AuthService().me.avatarUrl!),
                                      ),
                                      itemBuilder: ((context) => [
                                            PopupMenuItem(
                                                child: Text(
                                                    'see my location on the map'),
                                                onTap: () {}),
                                            PopupMenuItem(
                                                child: Text(
                                                    'share my location with ${friend.displayName}'),
                                                onTap: () {}),
                                          ]),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    )
                                  ])
                            : AppBar(
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 18.0),
                                  child: PopupMenuButton(
                                    child: eventData!.me.broadcasting
                                        ? CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.blue[900],
                                            child: CircleAvatar(
                                                radius: 16,
                                                backgroundImage: NetworkImage(
                                                    friend.avatarUrl!)))
                                        : CircleAvatar(
                                            backgroundImage: NetworkImage(
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
                                title: Row(
                                  children: [
                                    Text(
                                      friend.displayName!,
                                    )
                                  ],
                                ),
                                actions: [
                                  VerticalDivider(
                                    thickness: 2,
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  PopupMenuButton(
                                    child: eventData!.me.broadcasting
                                        ? CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.blue[900],
                                            child: CircleAvatar(
                                                radius: 17,
                                                backgroundImage: NetworkImage(
                                                    AuthService()
                                                        .me
                                                        .avatarUrl!)))
                                        : CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                AuthService().me.avatarUrl!),
                                          ),
                                    itemBuilder: ((context) => [
                                          PopupMenuItem(
                                              child: eventData!.me.broadcasting
                                                  ? Text(
                                                      'stop sharing my location',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )
                                                  : Text('share my location'),
                                              onTap: () {
                                                _firestore.toggleMyBroadcast(
                                                    friend.chatsID!,
                                                    eventData.me.broadcasting,
                                                    eventData.me);
                                              }),
                                          PopupMenuItem(
                                              child: Text('search map'),
                                              onTap: null),
                                          PopupMenuItem(
                                              child: Icon(
                                                Icons.my_location,
                                                color: Colors.blue,
                                              ),
                                              onTap: null),
                                        ]),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  )
                                ],
                              ),
                        body: Stack(children: [
                          SlidingUpPanel(
                              controller: _panelController,
                              maxHeight: MediaQuery.of(context).size.height,
                              minHeight: eventData.placeName == null ? 40 : 60,
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
                              body: GoogleMaps(
                                friend: friend,
                              ),
                              collapsed: eventData!.placeName == null
                                  ? Container(
                                      height: 10,
                                      color: Colors.blue,
                                      child: Center(
                                          child: Icon(
                                        Icons.drag_handle_outlined,
                                        color: Colors.white,
                                      )),
                                    )
                                  : AppBar(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black54,
                                      leading: Icon(
                                        Icons.location_on,
                                        color: Colors.purple,
                                      ),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            eventData.placeName!,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300),
                                          ),
                                          Text(
                                            eventData.address!,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w100),
                                          )
                                        ],
                                      ),
                                      actions: [
                                        VerticalDivider(
                                          thickness: 1,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.near_me,
                                              )),
                                        ),
                                      ],
                                    ),
                              panel: Column(
                                children: [
                                  eventData.placeName == null
                                      ? Container()
                                      : ExpansionPanelList(
                                          expandedHeaderPadding:
                                              EdgeInsets.zero,
                                          dividerColor: Colors.red,
                                          elevation: 0,
                                          animationDuration:
                                              Duration(milliseconds: 500),
                                          expansionCallback:
                                              (int index, bool isExpanded) {
                                            _expandedEvent = !_expandedEvent;
                                            setState(() {});
                                          },
                                          children: [
                                            ExpansionPanel(
                                                body: AppBar(
                                                  backgroundColor: Colors.white,
                                                  // leading: OutlinedButton(
                                                  //   child: Icon(Icons.settings),
                                                  //   onPressed: () {},
                                                  // ),
                                                  actions: [
                                                    OutlinedButton(
                                                        onPressed: () {},
                                                        child: Icon(
                                                            Icons.more_time)),
                                                    OutlinedButton(
                                                        onPressed: () {},
                                                        child: Icon(
                                                            Icons.settings)),
                                                    OutlinedButton(
                                                      child: Icon(Icons.delete),
                                                      onPressed: () {
                                                        _firestore.deleteEvent(
                                                            friend.chatsID!);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                isExpanded: _expandedEvent,
                                                canTapOnHeader: false,
                                                headerBuilder: (context,
                                                        isExpanded) =>
                                                    ListTile(
                                                      dense: true,
                                                      leading: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {},
                                                            icon: Icon(
                                                              Icons.location_on,
                                                              color:
                                                                  Colors.purple,
                                                            ),
                                                          ),
                                                          VerticalDivider()
                                                        ],
                                                      ),
                                                      title: Text(
                                                          eventData.placeName!),
                                                      subtitle: Text(eventData
                                                          .address!
                                                          .substring(0, 34)),
                                                    ))
                                          ],
                                        ),
                                  // Divider(),
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
                                              itemBuilder: ((context, index) {
                                                return Row(
                                                  mainAxisAlignment: data[index]
                                                              .uid ==
                                                          _auth.me.uid
                                                      ? MainAxisAlignment.end
                                                      : MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 2),
                                                        // color: Colors.blue[100],
                                                        child: Material(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .blue)),
                                                          color: data[index]
                                                                      .uid ==
                                                                  _auth.me.uid
                                                              ? null
                                                              : Colors.blue,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              data[index].text,
                                                              style: TextStyle(
                                                                  color: data[index].uid ==
                                                                          _auth
                                                                              .me
                                                                              .uid
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors
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
                              )),
                          panelOpen
                              ? Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
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
                                                          BorderRadius.circular(
                                                              10.0),
                                                      borderSide:
                                                          BorderSide.none),
                                                  fillColor: Colors.blue[50],
                                                  hintText: panelOpen
                                                      ? '    send a message'
                                                      : '    use top search bar for now'),
                                              controller: panelOpen
                                                  ? _controller
                                                  : _searchController,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _firestore.sendMessage(message,
                                                    friend.chatsID!.id);
                                                _controller.clear();
                                              },
                                              child: Icon(Icons.send),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Container()
                        ]));
                  }
                  return Text('chat loading');
                }),
          );
  }

  TimeOfDay? _time;

  void _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: _time ?? const TimeOfDay(hour: 8, minute: 00),
        initialEntryMode: TimePickerEntryMode.input);

    if (newTime != null) {
      setState(() {
        _time = newTime;
      });
      FirestoreService().addEventTime(friend.chatsID!, newTime);
    }
  }

  togglePlanning() {
    setState(() {
      planning = !planning;
    });
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
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        actions: [
                          IconButton(
                            onPressed: null,
                            icon: Icon(Icons.more_time),
                          ),
                          IconButton(onPressed: () {}, icon: Icon(Icons.event)),
                          IconButton(
                              onPressed: () {
                                _firestore.addLocation(
                                    friend.chatsID!,
                                    LatLng(43.723598, -79.598046),
                                    'bad name',
                                    'bad addy');
                              },
                              icon: Icon(Icons.add_location_alt)),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _firestore.deleteEvent(friend.chatsID!);
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                autofocus: true,
                                onChanged: (val) {
                                  eventName = val;
                                },
                                controller: _nameEventController,
                                decoration: InputDecoration(
                                    hintText: eventData!.event == null
                                        ? 'for ie. Raptors Game'
                                        : "edit: '${eventData.event}'"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    _firestore.addEvent(
                                        friend.chatsID!, eventName);
                                    _nameEventController.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Icon(Icons.check)),
                            )
                          ],
                        ),
                      ),
                    ],
                  )));
        });
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
