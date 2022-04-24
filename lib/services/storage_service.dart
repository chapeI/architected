import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  // final AuthService _authService = getIt.get<AuthService>();

  Future<String> uploadFile(String uid, File imagePath) async {
    Reference storageRef =
        _storage.ref().child('users/profilePictures/$uid.jpg');
    UploadTask uploadTask = storageRef.putFile(imagePath);
    // this is causing issues if the picture is too large. TODO: fix
    var url = 'THIS IS CAUSING ISSUES';
    uploadTask.whenComplete(() async {
      url = await storageRef.getDownloadURL();
      print('await url: $url');
      return url;
    }).catchError((e) {
      print('uploadTask error: $e');
    });
    await Future.delayed(const Duration(seconds: 3));
    return url;
  }

  Future<String> downloadUrl(uid) async {
    String downloadUrl =
        await _storage.ref('users/profilePictures/$uid.jpg').getDownloadURL();
    return downloadUrl;
  }
}
