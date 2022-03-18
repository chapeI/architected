// ignore_for_file: prefer_const_constructors

import 'package:architectured/locator.dart';
import 'package:architectured/user_controller.dart';
import 'package:architectured/views/home_view.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  static String route = 'login';
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  var emailController = TextEditingController(text: "test@test.com");
  var passwordController = TextEditingController(text: "1234567");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Form(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: InputDecoration(hintText: 'Email'),
              controller: emailController,
            ),
            TextFormField(
              decoration: InputDecoration(hintText: 'Password'),
              controller: passwordController,
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              child: Text('Sign In'),
              onPressed: () async {
                try {
                  await locator
                      .get<UserController>()
                      .signIn(emailController.text, passwordController.text);
                  Navigator.pushNamed(context, HomeView.route);
                } catch (e) {
                  print('somethings up: $e');
                }
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: null, child: Text('Register'))
          ],
        )),
      ),
    );
  }
}
