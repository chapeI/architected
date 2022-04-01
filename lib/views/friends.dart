import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/views/auth_views/sign_out.dart';
import 'package:flutter/material.dart';

class Friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
        stream: FirestoreService().friends,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final friends = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  actions: [AddFriendButton(), SignOut()]),
              body: ListView.builder(
                  itemCount: friends!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(friends[index].email!),
                      leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(friends[index].avatarUrl!)),
                      onTap: () {
                        // print(friends[index].displayName); // displayName not working
                        Navigator.pop(context, friends[index]);
                      },
                    );
                  }),
            );
          }
          return LinearProgressIndicator();
        });
  }
}

class AddFriendButton extends StatelessWidget {
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.person_add),
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
