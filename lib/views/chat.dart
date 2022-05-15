import 'package:architectured/models/chat_model.dart';
import 'package:architectured/models/event_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/views/maps2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                      'since this is still alpha, data structures change on the fly. That means chats may be deleted on updates. if your profile picture isnt showing up CLICK THIS BUTTON. dont add anyone if your profile picture isnt working. if you want a feature to be developed, poll it here '),
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
              if (_panelController.isPanelClosed) {
                // closing the panel before going to friends.dart
                _panelController.open();
                return false;
              }
              FocusManager.instance.primaryFocus?.unfocus();
              final result = await Navigator.pushNamed(context, '/friends');
              setState(() {
                friend = result as UserModel;
              });
              return false;
            },
            child: StreamProvider<EventModel?>.value(
                value: _firestore.events(friend.chatsID!),
                initialData: null,
                builder: (context, snapshot) {
                  if (true) {
                    var eventData = Provider.of<EventModel>(context);
                    return Theme(
                      data: eventData!.me.broadcasting
                          ? ThemeData.from(
                              colorScheme: ColorScheme.fromSwatch(
                                  primarySwatch: Palette.kToDark))
                          : Theme.of(context),
                      child: Builder(
                        builder: (context) => Scaffold(
                            appBar: mapMode
                                ? AppBar(
                                    title: Text(
                                      friend.displayName!,
                                      style: TextStyle(
                                          color: eventData.friend.broadcasting
                                              ? Colors.green[700]
                                              : null),
                                    ),
                                    elevation: 0,
                                    leading: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0),
                                      child: Icon(Icons.cancel),
                                      onPressed: () {
                                        _panelController.open();
                                      },
                                    ),
                                  )
                                : AppBar(
                                    title: Text(
                                      friend.displayName!,
                                      style: TextStyle(
                                          color: eventData.friend.broadcasting
                                              ? Colors.green[700]
                                              : null),
                                    ),
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          onPressed: () async {
                                            final result =
                                                await Navigator.pushNamed(
                                                    context, '/friends');
                                            setState(() {
                                              friend = result as UserModel;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.chevron_left,
                                          ),
                                        ),
                                        Flexible(
                                          child: PopupMenuButton(
                                            child: eventData!
                                                    .friend.broadcasting
                                                ? CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        Colors.green[800],
                                                    child: CircleAvatar(
                                                      radius: 13,
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
                                                          'woah only if friend is broadcasting will i see this'))
                                                ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    elevation: 0,
                                    actions: [
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
                                                    onTap: () {}),
                                                PopupMenuItem(
                                                    child: Text(
                                                        'search (go to map mode first)'),
                                                    onTap: () {
                                                      _panelController.close();
                                                    }),
                                              ]),
                                        ),
                                      ]),
                            body: Stack(children: [
                              SlidingUpPanel(
                                  controller: _panelController,
                                  maxHeight: MediaQuery.of(context).size.height,
                                  minHeight:
                                      eventData.placeName == null ? 0 : 45,
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
                                  body: Maps2(
                                    friend: friend,
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
                                                    color:
                                                        Colors.purple.shade300,
                                                    size: 15,
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      eventData.placeName!,
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .inversePrimary,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      '(${eventData.address!})',
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .inversePrimary,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  ),
                                                  IconButton(
                                                      padding: EdgeInsets.only(
                                                          left: 5),
                                                      constraints:
                                                          BoxConstraints(),
                                                      icon: Icon(
                                                        Icons.settings,
                                                        size: 15,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .inversePrimary,
                                                      ),
                                                      onPressed: () {})
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

  void openChat() {
    _panelController.open();
  }
}

class Palette {
  static const MaterialColor kToDark = const MaterialColor(
    0xffdcedc8, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: const Color(0xffce5641), //10%
      100: const Color(0xffb74c3a), //20%
      200: const Color(0xffa04332), //30%
      300: const Color(0xff89392b), //40%
      400: const Color(0xff733024), //50%
      500: const Color(0xff5c261d), //60%
      600: const Color(0xff451c16), //70%
      700: const Color(0xff2e130e), //80%
      800: const Color(0xff170907), //90%
      900: const Color(0xff000000), //100%
    },
  );
} // you can define define int 500 as the default shade and add your lighter tints above and darker tints below.