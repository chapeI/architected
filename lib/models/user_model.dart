class UserModel {
  String? uid;
  String? email;
  String? displayName;
  String? avatarUrl;

  UserModel(
      {required this.uid,
      required this.email,
      this.displayName,
      this.avatarUrl});
}

class SimpleUserModel {
  String email;
  SimpleUserModel({required this.email});
}
