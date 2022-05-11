import 'package:architectured/models/event_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/firestore_service.dart';
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
                    style: TextStyle(color: Colors.pink[300], fontSize: 12),
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
                            return ListTile(
                              title: Text(
                                friends[index].displayName!,
                                style: eventData!.friend.broadcasting
                                    ? TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold)
                                    : null,
                              ),
                              tileColor: eventData.me.broadcasting
                                  ? Colors.lightGreen[100]
                                  : null,
                              leading: eventData.friend.broadcasting
                                  ? CircleAvatar(
                                      backgroundColor: Colors.green,
                                      radius: 20,
                                      child: CircleAvatar(
                                          radius: 17,
                                          backgroundImage: NetworkImage(
                                              friends[index].avatarUrl!)),
                                    )
                                  : CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          friends[index].avatarUrl!),
                                    ),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  eventData.placeName == null
                                      ? Container()
                                      : Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 15,
                                              color: Colors.purple,
                                            ),
                                            Text(
                                              '${eventData.placeName} ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                  Expanded(
                                    child: Text(
                                      eventData!.lastMessage,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
