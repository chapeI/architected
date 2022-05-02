import 'package:architectured/models/event_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/services/user_controller.dart';
import 'package:architectured/views/auth_views/sign_out.dart';
import 'package:flutter/material.dart';

class Friends extends StatelessWidget {
  TimeOfDay? _time;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirestoreService().friends,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<UserModel>? friends = snapshot.data as List<UserModel>;
            return Scaffold(
              appBar: AppBar(
                  elevation: 0,
                  title: Text(
                    AuthService().me.uid!,
                    style: TextStyle(color: Colors.blue[300], fontSize: 12),
                  ),
                  automaticallyImplyLeading: false,
                  actions: [
                    PopupMenuButton(
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(AuthService().me.avatarUrl!),
                        ),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                                child: TextButton(
                              onPressed: () {},
                              child: Text('create a group'),
                            )),
                            PopupMenuItem(child: AddFriendButton()),
                            PopupMenuItem(child: SignOut()),
                          ];
                        }),
                    SizedBox(
                      width: 20,
                    ),
                  ]),
              body: ListView.builder(
                  itemCount: friends!.length,
                  itemBuilder: (context, index) {
                    return StreamBuilder<EventModel>(
                        stream:
                            FirestoreService().events(friends[index].chatsID!),
                        builder: (context, snapshot2) {
                          if (snapshot2.hasData) {
                            var eventData = snapshot2.data;
                            if (eventData!.hour == null) {
                              _time = null;
                            } else {
                              _time = TimeOfDay(
                                  hour: eventData.hour!,
                                  minute: eventData.minute!);
                            }
                            return ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(friends[index].displayName!),
                                  Text(
                                    '11:01AM',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w100,
                                        fontSize: 8),
                                  )
                                ],
                              ),
                              dense: true,
                              tileColor: eventData.me.broadcasting
                                  ? Colors.green[50]
                                  : null,
                              leading: eventData.friend.broadcasting
                                  ? CircleAvatar(
                                      backgroundColor: Colors.green,
                                      radius: 20,
                                      child: CircleAvatar(
                                          radius: 18,
                                          backgroundImage: NetworkImage(
                                              friends[index].avatarUrl!)),
                                    )
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          friends[index].avatarUrl!),
                                    ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(eventData!.lastMessage),
                                  Row(
                                    children: [
                                      eventData.placeName == null
                                          ? Container()
                                          : Icon(
                                              Icons.location_on,
                                              color: Colors.purple,
                                              size: 18,
                                            )
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pop(context, friends[index]);
                              },
                            );
                          }
                          return Text(
                              'DEBUG: missing a field (ie. hour) in this chatroom document');
                        });
                  }),
            );
          }
          return Text('FRIENDS.dart');
        });
  }
}

class AddFriendButton extends StatelessWidget {
  Widget build(BuildContext context) {
    return TextButton(
      child: Text('add friends'),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFriendScreen(),
            ));
      },
    );
  }
}

class AddFriendScreen extends StatefulWidget {
  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
        future: FirestoreService().addUserList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final users = snapshot.data;
            return Scaffold(
              appBar: AppBar(title: const Text('add friends')),
              body: ListView.builder(
                  itemCount: users!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(users[index].displayName!),
                      leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(users[index].avatarUrl!)),
                      trailing: ElevatedButton(
                          child: const Text('add'),
                          onPressed: () {
                            FirestoreService().addFriend(users[index]);
                            Navigator.pop(context);
                          }),
                    );
                  }),
            );
          }
          return LinearProgressIndicator();
        });
  }
}
