import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/database_service.dart';
import 'package:architectured/services/user_controller.dart';
import 'package:flutter/material.dart';

import '../services/singletons.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('home view'),
        actions: [SignOutButton()],
      ),
      body: Text('helo'),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddFriendScreen()));
        },
        child: const Text('add'),
      ),
    );
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
                      title: Text(users[index].displayName!),
                    );
                  }),
            );
          }
          return const Text('bad if?');
        });
  }
}
