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
  final _panelController = PanelController();

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
                      body: GoogleMaps(),
                      panel: StreamBuilder<EventModel>(
                          stream: _firestore.events(friend.chatsID!),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              EventModel? eventData = snapshot.data;
                              // return eventData!.event == null
                              //     ? Column(
                              //         children: [
                              //           ListTile(
                              //             title: Text(friend.email!),
                              //             leading: CircleAvatar(
                              //               backgroundImage:
                              //                   NetworkImage(friend.avatarUrl!),
                              //             ),
                              //             trailing: IconButton(
                              //               icon: Icon(
                              //                 Icons.add,
                              //               ),
                              //               onPressed: () {
                              //                 showModal(context, eventData);
                              //               },
                              //             ),
                              //           ),
                              //         ],
                              //       )
                              return Column(
                                children: [
                                  eventData!.event == null
                                      ? ListTile(
                                          leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  friend.avatarUrl!)),
                                          title: Row(
                                            children: [
                                              Text(' ${friend.email!}')
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
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons
                                                      .check_circle_outline_outlined,
                                                  color: Colors.green,
                                                ),
                                                onPressed: () {},
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.location_on,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  _panelController.close();
                                                },
                                              ),
                                            ],
                                          ),
                                          subtitle:
                                              Text('5PM at Graden Gordon'),
                                          title: Row(
                                            children: [
                                              Text('${eventData!.event} w '),
                                              CircleAvatar(
                                                radius: 8,
                                                backgroundImage: NetworkImage(
                                                    friend.avatarUrl!),
                                              ),
                                              Text(' ${friend.email!}')
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
