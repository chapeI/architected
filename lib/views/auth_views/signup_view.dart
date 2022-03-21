// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class SignUpView extends StatelessWidget {
  Function toggleAuthView;
  SignUpView({required this.toggleAuthView});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign up')),
      body: Center(
          child: ElevatedButton(
        child: Text('Log In'),
        onPressed: () {
          toggleAuthView();
        },
      )),
    );
  }
}
