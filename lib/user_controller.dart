import 'dart:io';

import 'package:architectured/locator.dart';
import 'package:architectured/repos/auth_repo.dart';
import 'package:architectured/repos/storage_repo.dart';
import 'package:architectured/user_model.dart';

class UserController {
// UserController sits bw UI and services, NOT UI AND FIREBASE, UserController shouldnt have any idea about FireBase. there should be no firebase code in there
  late UserModel _currentUser;
  late Future init;
  final AuthRepo _authRepo = locator.get<AuthRepo>();
  final StorageRepo _storageRepo = locator.get<StorageRepo>();

  UserController() {
    init = initUser();
  }

  Future<UserModel> initUser() async {
    _currentUser = await _authRepo.getUser();
    return _currentUser;
  }

  UserModel get currentUser => _currentUser;

  Future<String> getDownloadUrl() async {
    return await _storageRepo.getUserProfileImage(currentUser.uid);
  }

  Future<void> signIn(email, password) async {
    _currentUser = await _authRepo.signIn(email, password);
    _currentUser.avatarUrl = await getDownloadUrl();
  }

  Future<void> uploadProfilePicture(File file) async {
    _currentUser.avatarUrl = await _storageRepo.uploadFile(file);
  }
}
