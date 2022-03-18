class UserModel {
  String uid;
  String? displayName;
  String? avatarUrl;

  UserModel(this.uid, {this.avatarUrl, required this.displayName});
}
