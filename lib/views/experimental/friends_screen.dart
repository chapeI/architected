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
              appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: null,
                  ),
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
          return Text('no data in snapshot');
        });
  }
}

class AddFriendButton extends StatelessWidget {
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('add Friend'),
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
