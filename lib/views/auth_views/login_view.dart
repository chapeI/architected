// ignore_for_file: prefer_const_constructors

import 'package:architectured/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:architectured/singletons.dart';

class LoginView extends StatefulWidget {
  Function toggleAuthView;
  LoginView({required this.toggleAuthView});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    emailController.text = 'test@test.com';
    passwordController.text = '1234567';
    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
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
                child: Text('Sign In'),
                onPressed: () async {
                  try {
                    await getIt
                        .get<UserController>()
                        .signIn(emailController.text, passwordController.text);
                    Navigator.pushNamed(context, '/home');
                  } catch (e) {
                    print('error: $e');
                  }
                }),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  widget.toggleAuthView();
                },
                child: Text('Go to Sign Up'))
          ],
        ),
      ),
    );
  }
}
