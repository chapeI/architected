import 'package:architectured/services/singletons.dart';
import 'package:architectured/services/user_controller.dart';
import 'package:architectured/views/auth_views/auth_view.dart';
import 'package:architectured/views/auth_views/login_view.dart';
import 'package:flutter/material.dart';

class SignOut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await getIt.get<UserController>().signOut();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => AuthView()),
            (route) => false);
      },
      child: Text('signout2'),
    );
  }
}
