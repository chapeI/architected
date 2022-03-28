import 'package:architectured/models/chat_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
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
  final _auth = AuthService();
  final controller = TextEditingController();
  String message = '';

  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('this will be slideable')),
      body: Column(
        children: [
          StreamBuilder<List<ChatModel>>(
              stream: _firestore.getChats(widget.friend),
              builder: (((context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data;

                  return Expanded(
                    child: ListView.builder(
                        reverse: true,
                        itemCount: data!.length,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: data[index].uid == _auth.me.uid
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(4),
                                  color: Colors.blue[100],
                                  child: Text(data[index].text)),
                            ],
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
