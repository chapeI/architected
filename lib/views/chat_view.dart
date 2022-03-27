import 'package:architectured/models/chat_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  UserModel friend;
  ChatView({required this.friend});
  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _firestore = FirestoreService();
  final controller = TextEditingController();
  String message = '';

  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatModel>>(
        stream: _firestore.getChats(widget.friend),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var chats = snapshot.data;
            return Scaffold(
                appBar: AppBar(title: Text(widget.friend.email!)),
                body: Column(children: [
                  Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.all(4),
                        itemCount: chats!.length,
                        itemBuilder: ((context, index) {
                          return ListTile(
                            title: Text(chats[index].text),
                          );
                        })),
                  ),
                  Container(
                    child: Text('send'),
                  )
                ]));
          }
          return Container(
            child: const Text('null snapshot, or check shape'),
          );
        });
  }
}
