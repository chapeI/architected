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
                        appBar: AppBar(
                            backgroundColor: Colors.green[50],
                            foregroundColor: Colors.black,
                            title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(friend.displayName!),
                                  Text(
                                    'online',
                                    style: TextStyle(fontSize: 12),
                                  )
                                ]),
                            leading: Padding(
                              padding: const EdgeInsets.only(left: 18.0),
                              child: PopupMenuButton(
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.green,
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundImage:
                                        NetworkImage(friend.avatarUrl!),
                                  ),
                                ),
                                itemBuilder: ((context) => [
                                      PopupMenuItem(
                                          child: Text('view profile picture')),
                                      PopupMenuItem(
                                          child: Text(
                                              'request john to share his location'))
                                    ]),
                              ),
                            ),
                            elevation: 0,
                            actions: [
                              PopupMenuButton(
                                child: Icon(Icons.share_location),
                                itemBuilder: ((context) => [
                                      PopupMenuItem(
                                          child: Text(
                                              'broadcast for only 15 minutes'),
                                          onTap: () {}),
                                      PopupMenuItem(
                                          child: Text('broadcast location'),
                                          onTap: () {}),
                                    ]),
                              ),
                              PopupMenuButton(
                                itemBuilder: ((context) => [
                                      PopupMenuItem(
                                          child: Text('reveal map'),
                                          onTap: () {}),
                                      PopupMenuItem(
                                          child: Text(
                                              'request John to share his location'),
                                          onTap: () {}),
                                    ]),
                              )
                            ]),
                        body: Stack(children: [
                          SlidingUpPanel(
                              controller: _panelController,
                              maxHeight: MediaQuery.of(context).size.height,
                              minHeight: 60,
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
                                  ? AppBar(
                                      actions: [
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.my_location)),
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.search)),
                                      ],
                                    )
                                  : AppBar(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(eventData.placeName!),
                                          Text(
                                            eventData.address!,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w100),
                                          )
                                        ],
                                      ),
                                      actions: [
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.location_on,
                                            )),
                                        IconButton(
                                          onPressed: () {
                                            _firestore
                                                .deleteEvent(friend.chatsID!);
                                          },
                                          icon: Icon(Icons.delete),
                                        ),
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.my_location)),
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.search,
                                              color:
                                                  Colors.lightGreenAccent[400],
                                            )),
                                      ],
                                    ),
                              panel: Column(
                                children: [
                                  eventData.placeName == null
                                      ? Container()
                                      : Card(
                                          elevation: 0,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.all(8),
                                            title: Text(
                                                '${eventData.placeName!} (drag me)'),
                                            subtitle: Text(eventData.address!),
                                            trailing: IconButton(
                                                onPressed: () {},
                                                icon: Icon(Icons.swipe)),
                                          ),
                                        ),
                                  Divider(),
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
