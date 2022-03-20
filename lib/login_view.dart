// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    emailController.text = 'anoop@gmail.com';
    passwordController.text = 'test123';
    return Scaffold(
      appBar: AppBar(title: const Text('login')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'email'),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'password'),
            ),
            SizedBox(
              height: 8,
            ),
            ElevatedButton(
              child: Text('signin'),
              onPressed: null,
            )
          ],
        ),
      ),
    );
  }
}
