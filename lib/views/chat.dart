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
  final _eventController = TextEditingController();
  String message = '';
  String eventName = '';
  var panelOpen = true;
  final _panelController = PanelController();

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
                              return Column(
                                children: [
                                  eventData!.event == null
                                      ? ListTile(
                                          leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  friend.avatarUrl!)),
                                          title: Row(
                                            children: [
                                              Text(
                                                  ' ${friend.displayName ?? 'null error'}')
                                            ],
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () {
                                              showModal(context, eventData);
                                            },
                                          ))
                                      : ListTile(
                                          onTap: () {
                                            showModal(context, eventData);
                                          },
                                          trailing: IconButton(
                                            icon: Icon(
                                              Icons.location_on,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              _panelController.close();
                                            },
                                          ),
                                          title: Text(eventData.event ??
                                              'shouldnt see a null event'),
                                          isThreeLine: true,
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3.0),
                                                child: Text(
                                                    '5PM at Graden Gordon'),
                                              ),
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 8,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            friend.avatarUrl!),
                                                  ),
                                                  Text(' ${friend.email!}'),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 2.0),
                                                    child: Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color: Colors.green,
                                                      size: 15,
                                                    ),
                                                  )
                                                ],
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
                                'if you see this, tell anoop event field was deleted, create it again and set it to null');
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

  TimeOfDay _time = TimeOfDay(hour: 7, minute: 15);

  void _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: _time,
        initialEntryMode: TimePickerEntryMode.input);
    if (newTime != null) {
      setState(() {
        _time = newTime;
      });
    }
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
                        leading: IconButton(
                          icon: Icon(Icons.add_photo_alternate),
                          onPressed: null,
                        ),
                        backgroundColor: Colors.blue[200],
                        actions: [
                          TextButton(
                              onPressed: _selectTime,
                              child: Text('${_time.format(context)}')),
                          IconButton(
                              onPressed: null,
                              icon: Icon(Icons.add_location_alt)),
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
                                    hintText: eventData!.event == null
                                        ? 'make an event name'
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
