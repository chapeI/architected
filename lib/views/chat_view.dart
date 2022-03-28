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
    return Scaffold(
      appBar: AppBar(title: const Text('this will be slideable')),
      body: Column(
        children: [
          StreamBuilder<List<ChatModel>>(
              stream: _firestore.getChats(widget.friend),
              builder: (((context, snapshot) {
                if (snapshot.hasData) {
                  var chats = snapshot.data;
                  return Expanded(
                    child: ListView.builder(
                        itemCount: chats!.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(chats[index].text),
                            subtitle: Text(chats[index].sender),
                          );
                        }),
                  );
                }
                return Text('null snapshot, check shape');
              }))),
          Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (val) {
                        message = val;
                      },
                    ),
                  ),
                  TextButton(
                      child: Text('send'),
                      onPressed: () {
                        FirestoreService()
                            .sendMessage(message, widget.friend.chatsID!.id);
                      })
                ],
              ))
        ],
      ),
    );
  }
}
