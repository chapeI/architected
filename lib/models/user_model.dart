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
  String? email;
  String uid;
  SimpleUserModel({required this.email, required this.uid});
}
