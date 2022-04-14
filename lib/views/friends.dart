import 'package:architectured/models/event_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/services/user_controller.dart';
import 'package:architectured/views/auth_views/sign_out.dart';
import 'package:flutter/material.dart';

class Friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirestoreService().friends,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<UserModel>? friends = snapshot.data as List<UserModel>;

            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: Icon(Icons.add),
              ),
              appBar: AppBar(
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                              UserController().currentUser.avatarUrl!)),
                    ),
                  ),
                  title: Text(AuthService().me.displayName!),
                  automaticallyImplyLeading: false,
                  actions: [
                    PopupMenuButton(itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                            child: TextButton(
                          onPressed: () {},
                          child: Text('create a group'),
                        )),
                        PopupMenuItem(child: AddFriendButton()),
                        PopupMenuItem(child: SignOut()),
                      ];
                    })
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
                              title: Text(friends[index].displayName!),
                              leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(friends[index].avatarUrl!)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  eventData!.event == null
                                      ? Container()
                                      : Text('Event: ${eventData.event}'),
                                  Text(eventData.lastMessage),
                                ],
                              ),
                              onTap: () {
                                Navigator.pop(context, friends[index]);
                              },
                            );
                          }
                          return Text('why would I see this?');
                        });
                  }),
            );
          }
          return LinearProgressIndicator();
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
