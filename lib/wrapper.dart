import 'package:architectured/views/auth_views/auth_view.dart';
import 'package:architectured/views/chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var uid = Provider.of<String?>(context);
    if (uid == null) {
      return AuthView();
    } else {
      return Chat();
    }
  }
}
