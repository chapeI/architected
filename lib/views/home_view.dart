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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {},
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
