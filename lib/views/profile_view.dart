import 'dart:io';

import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  // UserModel _currentUser = locator.get<UserController>.currentUser;
  String? url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: url == null
                  ? CircleAvatar(
                      child: Icon(Icons.add_reaction_outlined),
                    )
                  : CircleAvatar(
                      backgroundImage: NetworkImage(url!),
                    ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('welcome current user'),
          ],
        ),
      ),
    );
  }
}
