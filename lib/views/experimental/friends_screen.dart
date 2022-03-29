import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/views/auth_views/sign_out.dart';
import 'package:architectured/views/experimental/add_friend_screen.dart';
import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
        stream: FirestoreService().friends,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final friends = snapshot.data;
            return Scaffold(
              appBar: AppBar(actions: [SignOut()]),
              body: ListView.builder(
                  itemCount: friends!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(friends[index].email!),
                      leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(friends[index].avatarUrl!)),
                      onTap: () {
                        // doesnt work..
                        print(friends[index].displayName);
                        Navigator.pop(context, friends[index].uid);
                      },
                    );
                  }),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddFriendScreen(),
                      ));
                },
                child: Text('add'),
              ),
            );
          }
          return Text('no data in snapshot');
        });
  }
}
