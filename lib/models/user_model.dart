class UserModel {
  String uid;
  String? email;
  String? displayName;
  String? avatarUrl;

  UserModel({required this.uid, required this.email, this.displayName});
}
