import 'dart:async';

import 'package:architectured/models/chat_model.dart';
import 'package:architectured/models/event_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  // MAP STUFF
  final Completer<GoogleMapController> _mapController = Completer();
  final _searchController = TextEditingController();

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12)));
  }

  @override
  Widget build(BuildContext context) {
    return friend.uid == null
        ? Scaffold(
            appBar: AppBar(title: Text('welcome to chatsdev v1.0')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                    child: Text(
                        'data structure might have to change, so your convos might be wiped when the next version rolls around. click this button to fix profile picture, message me directly here, post issues among testers here')),
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
                      minHeight: 140,
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
                      body: GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: LatLng(43, -79)),
                        onMapCreated: (GoogleMapController controller) {
                          _mapController.complete(controller);
                        },
                      ),
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
                              return Column(
                                children: [
                                  eventData!.event == null
                                      ? Container(
                                          decoration: BoxDecoration(
                                              color: Colors.blue[50]),
                                          child: ListTile(
                                              leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      friend.avatarUrl!)),
                                              title: Row(
                                                children: [
                                                  Text(
                                                      ' ${friend.displayName ?? 'null error'}')
                                                ],
                                              ),
                                              trailing: planning
                                                  ? IconButton(
                                                      icon: Icon(Icons.add),
                                                      onPressed: togglePlanning,
                                                    )
                                                  : Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                            icon: Icon(
                                                                Icons.check),
                                                            onPressed: () {
                                                              _firestore.addEvent(
                                                                  friend
                                                                      .chatsID!,
                                                                  eventName);
                                                              _nameEventController
                                                                  .clear();
                                                              togglePlanning();
                                                            }),
                                                        IconButton(
                                                          icon: Icon(Icons
                                                              .highlight_off),
                                                          onPressed:
                                                              togglePlanning,
                                                        ),
                                                      ],
                                                    )),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                              color: Colors.blue[50]),
                                          child: ListTile(
                                            onTap: togglePlanning,
                                            trailing: planning
                                                ? Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {
                                                            showModal(context,
                                                                eventData);
                                                          },
                                                          icon: Icon(Icons
                                                              .bug_report)),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.location_on,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () {
                                                          _panelController
                                                              .close();
                                                        },
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                          icon:
                                                              Icon(Icons.check),
                                                          onPressed: () {
                                                            _firestore.addEvent(
                                                                friend.chatsID!,
                                                                eventName);
                                                            _nameEventController
                                                                .clear();
                                                            togglePlanning();
                                                          }),
                                                      IconButton(
                                                        icon:
                                                            Icon(Icons.delete),
                                                        onPressed: () {
                                                          _firestore.deleteEvent(
                                                              friend.chatsID!);
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                            Icons.expand_less),
                                                        onPressed:
                                                            togglePlanning,
                                                      ),
                                                    ],
                                                  ),
                                            title: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(friend.displayName!),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Icon(
                                                  Icons
                                                      .check_circle_outline_rounded,
                                                  size: 15,
                                                  color: Colors.green,
                                                )
                                              ],
                                            ),
                                            leading: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    friend.avatarUrl!)),
                                            subtitle: eventData.hour == null
                                                ? Text(
                                                    'Coming up: ${eventData.event}')
                                                : Text(
                                                    '${eventData.event} @${_time!.format(context)}'),
                                          ),
                                        ),
                                  AnimatedSwitcher(
                                      duration: Duration(milliseconds: 150),
                                      child: planning
                                          ? Container(
                                              key: Key('1'),
                                            )
                                          : Container(
                                              key: Key('2'),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(13),
                                                  bottomRight:
                                                      Radius.circular(13),
                                                ),
                                              ),
                                              child: altModal(eventData),
                                            )),
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
                                                          color: data[index]
                                                                      .uid ==
                                                                  _auth.me.uid
                                                              ? Colors
                                                                  .lightBlue[50]
                                                              : Colors.blue,
                                                          borderRadius:
                                                              data[index].uid ==
                                                                      _auth.me
                                                                          .uid
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
                                                                      topRight:
                                                                          Radius.circular(
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
                                                                      topRight:
                                                                          Radius.circular(
                                                                              5),
                                                                    ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              data[index].text,
                                                              style: TextStyle(
                                                                  color: data[index]
                                                                              .uid ==
                                                                          _auth
                                                                              .me
                                                                              .uid
                                                                      ? null
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
                                          await _goToPlace(place);
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

  ListTile altModal(EventModel? eventData) {
    return ListTile(
      title: TextField(
        decoration: InputDecoration(
            hintText: eventData!.event == null
                ? 'write here!'
                : 'edit ${eventData.event}'),
        controller: _nameEventController,
        onChanged: (val) {
          eventName = val;
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          eventData.hour == null
              ? IconButton(onPressed: _selectTime, icon: Icon(Icons.more_time))
              : IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.schedule,
                    color: Colors.green,
                  )),
          IconButton(onPressed: null, icon: Icon(Icons.add_task_outlined)),
          IconButton(
              onPressed: null, icon: Icon(Icons.person_add_alt_1_outlined)),
          IconButton(onPressed: null, icon: Icon(Icons.add_location_alt)),
        ],
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
                              icon: Icon(Icons.add_location_alt)),
                          _time == null
                              ? IconButton(
                                  icon: Icon(Icons.more_time),
                                  onPressed: _selectTime,
                                )
                              : TextButton(
                                  onPressed: _selectTime,
                                  child: Text(
                                    '${_time!.format(context)}',
                                    style: TextStyle(color: Colors.white),
                                  )),
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
                                controller: _nameEventController,
                                decoration: InputDecoration(
                                    hintText: eventData!.event == null
                                        ? 'make an event name'
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
                                  child: Text('Create Event')),
                            )
                          ],
                        ),
                      ),
                    ],
                  )));
        });
  }
}
