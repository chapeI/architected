import 'package:flutter/material.dart';

class Pop extends StatelessWidget {
  Widget build(BuildContext context) {
    var goToUsers = FloatingActionButton(onPressed: () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UsersScreen()));
    });
    return Scaffold(
      body: ChatMap(),
      floatingActionButton: goToUsers,
    );
  }
}

class ChatMap extends StatelessWidget {
  const ChatMap({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('map'));
  }
}

class UsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pop animation'),
      ),
      body: Center(child: Text('users')),
    );
  }
}
