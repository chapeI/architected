import 'dart:io';

import 'package:architectured/locator.dart';
import 'package:architectured/user_controller.dart';
import 'package:architectured/user_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileView extends StatefulWidget {
  static String route = 'profile';

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final UserModel _currentUser = locator.get<UserController>().currentUser;

  String? url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Avatar(
              avatarUrl: _currentUser.avatarUrl,
              onTap: () async {
                final pickedImage =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                File pickedImageFile = File(pickedImage!.path);
                await locator
                    .get<UserController>()
                    .uploadProfilePicture(pickedImageFile);

                setState(() {});
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Text('hello ${_currentUser.displayName ?? '(no ones here)'} !'),
          ],
        ),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onTap;

  Avatar({required this.avatarUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Center(
          child: avatarUrl == null
              ? const CircleAvatar(
                  radius: 50,
                )
              : CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(avatarUrl!),
                ),
        ));
  }
}
