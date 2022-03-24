import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/database_service.dart';
import 'package:architectured/services/user_controller.dart';
import 'package:flutter/material.dart';

import '../services/singletons.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SimpleUserModel>>(
        stream: DatabaseService().myFriends,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final myFriends = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                title: const Text('home view'),
                actions: [SignOutButton()],
              ),
              body: ListView.builder(
                  itemCount: myFriends!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(myFriends[index].email),
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
          return const Text('null snapshot');
        });
  }
}

class SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          await getIt.get<UserController>().signOut();
          // Navigator.pushAndRemoveUntil(context, "/auth", (route) => false);
          Navigator.popUntil(context, ModalRoute.withName('/auth'));
        },
        child: const Text('signout'));
  }
}

class AddFriendScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
        stream: getIt.get<DatabaseService>().all,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final users = snapshot.data;
            return Scaffold(
              appBar: AppBar(title: Text('add friends ')),
              body: ListView.builder(
                  itemCount: users!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(users[index].avatarUrl!)),
                      title: Text(users[index].displayName!),
                    );
                  }),
            );
          }
          return const Text('bad if?');
        });
  }
}
