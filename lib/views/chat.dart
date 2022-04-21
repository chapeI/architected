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
import 'package:architectured/services/location_service.dart';
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
  bool expandedTile = false;
  LatLng? latLng;
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return friend.uid == null
        ? Scaffold(
            appBar: AppBar(title: Text('welcome to chatsdev v1.0')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'firestore document structure may change in the future. were still in alpha. That means convos may be deleted. click here if profile picture doesnt show up. get in touch w me directly here, post issues or desired features here '),
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
            child: Scaffold(
              body: SafeArea(
                child: Stack(children: [
                  SlidingUpPanel(
                      controller: _panelController,
                      maxHeight: MediaQuery.of(context).size.height,
                      minHeight: expandedTile ? 210 : 140,
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
                      body: GoogleMaps(),
                      panel: StreamBuilder<EventModel>(
                          stream: _firestore.events(friend.chatsID!),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              EventModel? eventData = snapshot.data;
                              if (eventData!.hour == null) {
                                _time = null;
                              } else {
                                _time = TimeOfDay(
                                    hour: eventData.hour!,
                                    minute: eventData.minute!);
                              }
                              eventData.location == null
                                  ? latLng = null
                                  : latLng = LatLng(
                                      eventData.location!.latitude,
                                      eventData.location!.longitude);
                              return Column(
                                children: [
                                  eventData!.event == null
                                      ? ListTile(
                                          leading: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      friend.avatarUrl!)),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              CircleAvatar(
                                                  child:
                                                      Icon(Icons.location_on)),
                                            ],
                                          ),
                                          title: Text(
                                              '${friend.displayName ?? 'null error'}'),
                                          subtitle:
                                              Text('25 Benoth Ave, Brampton'),
                                          trailing: IconButton(
                                            icon: Icon(Icons.more_vert),
                                            onPressed: null,
                                          ),
                                        )
                                      : ExpansionTile(
                                          collapsedIconColor: Colors.white,
                                          subtitle: Row(
                                            children: [
                                              Text(
                                                'Added: ',
                                              ),
                                              Text(
                                                '${eventName}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  friend.avatarUrl!)),
                                          trailing: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(
                                                Icons.location_on,
                                                color: Colors.purple,
                                              ),
                                              onPressed: () async {
                                                _panelController.close();
                                              }),
                                          title: Text(friend.displayName!),
                                          onExpansionChanged: (val) {
                                            setState(() {
                                              expandedTile = val;
                                            });
                                          },
                                          children: [
                                            AppBar(
                                              backgroundColor: Colors.white,
                                              elevation: 0,
                                              actions: [
                                                IconButton(
                                                    onPressed: () {},
                                                    icon: Icon(Icons
                                                        .add_location_alt)),
                                                IconButton(
                                                    onPressed: _selectTime,
                                                    icon:
                                                        Icon(Icons.more_time)),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: ElevatedButton.icon(
                                                    label: Text(
                                                        "${eventData.event}"),
                                                    icon: Icon(Icons.settings),
                                                    onPressed: () {
                                                      showModal(
                                                          context, eventData);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            ListTile(
                                              title: Text(
                                                  'TicketMaster reserved 3 tickets'),
                                              subtitle: Text('ACC Center'),
                                              trailing: Icon(Icons.pending),
                                            ),
                                            ListTile(
                                              leading: CircleAvatar(
                                                  backgroundImage: AssetImage(
                                                      'assets/pp2.jpeg')),
                                              title: Text(
                                                  'Caroline purchased her ticket'),
                                              subtitle: Text(
                                                  '\$10 paid to TicketMaster'),
                                              trailing: Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                            )
                                            // Text(
                                            //     'event details, purchased, confirms, '),
                                          ],
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
                                                                      .lightBlueAccent)),
                                                          color: data[index]
                                                                      .uid ==
                                                                  _auth.me.uid
                                                              ? null
                                                              : Colors
                                                                  .lightBlueAccent,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              data[index].text,
                                                              style: TextStyle(
                                                                  color: data[index]
                                                                              .uid ==
                                                                          _auth.me
                                                                              .uid
                                                                      ? Colors
                                                                          .lightBlueAccent
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
                              );
                            }
                            return Text(
                                'event field may have been deleted, create it again and set it to null');
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
                                controller:
                                    panelOpen ? _controller : _searchController,
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
                                        onPressed: () async {
                                          var place = await LocationService()
                                              .getPlace(_searchController.text);
                                          // await _goToPlace(place);
                                        },
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
    if (eventData!.hour == null) {
      _time = null;
    } else {
      _time = TimeOfDay(hour: eventData.hour!, minute: eventData.minute!);
    }

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
                                _firestore.addLocation(friend.chatsID!,
                                    LatLng(43.723598, -79.598046));
                              },
                              icon: Icon(Icons.add_location_alt)),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _firestore.deleteEvent(friend.chatsID!);
                              setState(() {
                                expandedTile = false;
                              });
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
