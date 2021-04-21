import 'package:chat_demo/Utils/global_values.dart';
import 'package:chat_demo/models/chat_message_model.dart';
import 'package:chat_demo/models/user_model.dart';
import 'package:chat_demo/widget/chat_title_widget.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _chatTextFieldController;
  List<ChatMessageModel> chatMessagesList;
  UserOnlineStatus status;
  User _pairedUser;
  @override
  void initState() {
    super.initState();
    chatMessagesList = List();
    _pairedUser = GlobalValues.pairedWithUser;
    status = UserOnlineStatus.connecting;
    _chatTextFieldController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: ChatTitle(chatUser: _pairedUser, userOnlineStatus: status)),
        body: SafeArea(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _chatList(),
                _bottomChatArea(),
              ],
            ),
          ),
        ));
  }

  _chatList() {
    return Expanded(
        child: Container(
            child: ListView.builder(
                // cacheExtent: 100,
                // controller: _chatLVController,
                reverse: false,
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                itemCount: chatMessagesList.length,
                itemBuilder: (context, index) {
                  return Text(chatMessagesList[index].message);
                })));
  }

  _bottomChatArea() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          _chatTextArea(),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              // _sendButtonTap();
            },
          ),
        ],
      ),
    );
  }

  _chatTextArea() {
    return Expanded(
      child: TextField(
        controller: _chatTextFieldController,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.grey,
              width: 0.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.white,
              width: 0.0,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(10.0),
          hintText: 'Type message...',
        ),
      ),
    );
  }
}
