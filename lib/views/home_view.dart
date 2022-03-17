import 'package:architectured/views/profile_view.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);
  static String route = 'home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      appBar: AppBar(actions: [
        IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, ProfileView.route);
            })
      ]),
    );
  }
}
