// ignore_for_file: prefer_const_constructors

import 'package:architectured/singletons.dart';
import 'package:architectured/user_controller.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  Function toggleAuthView;
  SignUpView({required this.toggleAuthView});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    emailController.text = 'tester@test.com';
    passwordController.text = '1234567';

    return Scaffold(
      appBar: AppBar(title: Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: 'email'),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: 'password'),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  await getIt
                      .get<UserController>()
                      .register(emailController.text, passwordController.text);
                  Navigator.pushNamed(context, '/home');
                } catch (e) {
                  print('error: $e');
                }
              },
              child: Text('Sign Up')),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                widget.toggleAuthView();
              },
              child: Text('Go to Sign In'))
        ]),
      ),
    );
  }
}
