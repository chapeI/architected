import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/database_service.dart';
import 'package:architectured/services/user_controller.dart';
import 'package:flutter/material.dart';

import '../services/singletons.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
        stream: DatabaseService().friends,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final friends = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                title: const Text('home view'),
                actions: [SignOutButton()],
              ),
              body: ListView.builder(
                  itemCount: friends!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(friends[index].email!),
                      leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(friends[index].avatarUrl!)),
                      onTap: () {
                        print(friends[index].chatsID);
                      },
                    );
                  }),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddFriendScreen()));
                },
                child: const Text('add'),
              ),
            );
          }
          return const Text('null snapshot?');
        });
  }
}

class SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          await getIt.get<UserController>().signOut();
          Navigator.pushReplacementNamed(context, '/auth');
        },
        child: const Text('signout'));
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
        future: DatabaseService().addUserList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final users = snapshot.data;
            return Scaffold(
              appBar: AppBar(title: const Text('add friends')),
              body: ListView.builder(
                  itemCount: users!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(users[index].email!),
                      leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(users[index].avatarUrl!)),
                      trailing: ElevatedButton(
                          child: const Text('add'),
                          onPressed: () {
                            DatabaseService().addFriend(users[index]);
                            Navigator.pop(context);
                          }),
                    );
                  }),
            );
          }
          return const Text('bad if?');
        });
  }
}
