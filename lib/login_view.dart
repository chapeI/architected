// ignore_for_file: prefer_const_constructors

import 'package:architectured/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginView extends StatefulWidget {
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GetIt locator = GetIt.I;

  @override
  Widget build(BuildContext context) {
    emailController.text = 'test@test.com';
    passwordController.text = '1234567';
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
                onPressed: () async {
                  try {
                    await locator
                        .get<UserController>()
                        .signIn(emailController.text, passwordController.text);
                    Navigator.pushNamed(context, '/home');
                  } catch (e) {
                    print('error: $e');
                  }
                })
          ],
        ),
      ),
    );
  }
}
