// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:architectured/services/singletons.dart';
import 'package:architectured/services/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUpView extends StatefulWidget {
  Function toggleAuthView;
  SignUpView({required this.toggleAuthView});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _pickedImagePath;

  Future<void> setImagePath() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage == null) return;
    final pickedImagePath = File(pickedImage.path);
    setState(() {
      _pickedImagePath = pickedImagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = 'tester';
    emailController.text = 'tester@test.com';
    passwordController.text = '1234567';

    return Scaffold(
      appBar: AppBar(title: Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(50),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _pickedImagePath == null
                        ? null
                        : FileImage(_pickedImagePath!),
                  ),
                ),
                Positioned(
                  left: 100,
                  top: 100,
                  child: ElevatedButton(
                    child: Icon(
                      Icons.add_reaction_outlined,
                      color: Colors.white,
                    ),
                    onPressed: setImagePath,
                  ),
                )
              ],
            ),
            TextFormField(
              controller: nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'name is required';
                }
                return null;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'name'),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'email is required';
                }
                return null;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'email'),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'password is required';
                }
                return null;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'password'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_pickedImagePath == null) {
                      showSnackBar(context,
                          'need a profile picture, click on the smiley above to add one');
                    } else {
                      try {
                        await getIt.get<UserController>().register(
                            emailController.text,
                            passwordController.text,
                            nameController.text,
                            _pickedImagePath);
                        Navigator.pushNamed(context, '/home');
                      } catch (e) {
                        showSnackBar(context, 'error: $e');
                      }
                    }
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
      ),
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    BuildContext context, message) {
  return ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}
