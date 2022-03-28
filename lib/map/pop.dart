import 'package:architectured/views/experimental/sliding_chat.dart';
import 'package:flutter/material.dart';

class Pop extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(body: SlidingChat(), floatingActionButton: fade(context));
  }

  FloatingActionButton normal(BuildContext context) {
    return FloatingActionButton(onPressed: () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UsersScreen()));
    });
  }

  FloatingActionButton fade(BuildContext context) {
    return FloatingActionButton(onPressed: () {
      Navigator.push(
          context,
          (PageRouteBuilder(
            pageBuilder: (c, a1, a2) => UsersScreen(),
            transitionsBuilder: (c, anim, a1, child) =>
                FadeTransition(opacity: anim, child: child),
            // transitionDuration: const Duration(milliseconds: 200)
          )));
    });
  }
}

class UsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pop animation'),
      ),
      body: Center(child: Text('users2')),
    );
  }
}