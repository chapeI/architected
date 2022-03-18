import 'dart:io';

import 'package:architectured/locator.dart';
import 'package:architectured/repos/auth_repo.dart';
import 'package:architectured/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageRepo {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthRepo _authRepo = locator.get<AuthRepo>();

  Future<String> uploadFile(File file) async {
    UserModel user = await _authRepo.getUser();
    var userUid = user.uid;

    Reference storageRef = _storage.ref().child('user/profile/$userUid');
    UploadTask uploadTask = storageRef.putFile(file);
    // md code had uploadTask.oncomplete, but this should work too
    var url = await uploadTask.snapshot.ref.getDownloadURL();
    return url;
  }

  Future<String> getUserProfileImage(String uid) async {
    return await _storage.ref().child('user/profile/$uid.jpg').getDownloadURL();
  }
}
