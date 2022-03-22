import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/singletons.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  // final AuthService _authService = getIt.get<AuthService>();

  void uploadFile() {}
  void getUserProfileImage() {}
}
