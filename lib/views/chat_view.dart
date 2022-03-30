import 'package:architectured/models/chat_model.dart';
import 'package:architectured/models/user_model.dart';
import 'package:architectured/services/auth_service.dart';
import 'package:architectured/services/firestore_service.dart';
import 'package:architectured/views/google_maps.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
    return SlidingUpPanel(
      // collapsed: Center(child: Text('event summary ?')),
      // header: Text('header we could perhaps use'),
      maxHeight: MediaQuery.of(context).size.height - 50,
      body: GoogleMaps(),
      panel: Column(
        children: [
          Container(
              padding: EdgeInsets.all(20),
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
              )),
          StreamBuilder<List<ChatModel>>(
              stream: _firestore.getChats(widget.friend),
              builder: (((context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data;
                  return Expanded(
                    child: ListView.builder(
                        reverse: false,
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
        ],
      ),
    );
  }
}
