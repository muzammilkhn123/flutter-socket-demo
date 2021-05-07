import 'package:chat_demo/models/user_model.dart';
import 'package:flutter/material.dart';

enum UserOnlineStatus { online, offline, connecting }

ChatTitleState chatTitleState;

class ChatTitle extends StatefulWidget {
  const ChatTitle(
      {Key key,
      @required this.chatUser,
      @required this.userOnlineStatus,
      @required this.isTyping})
      : super(key: key);

  final User chatUser;
  final UserOnlineStatus userOnlineStatus;
  final bool isTyping;

  @override
  ChatTitleState createState() => ChatTitleState();
}

class ChatTitleState extends State<ChatTitle> {
  static bool isTyping = false;
  @override
  Widget build(BuildContext context) {
    chatTitleState = this;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.chatUser.name),
          Text(
            isTyping ? "typing..." : _getStatusText(),
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.white70,
            ),
          )
        ],
      ),
    );
  }

  _getStatusText() {
    if (widget.userOnlineStatus == UserOnlineStatus.connecting) {
      return 'connecting...';
    }
    if (widget.userOnlineStatus == UserOnlineStatus.online) {
      return 'online';
    }
    if (widget.userOnlineStatus == UserOnlineStatus.offline) {
      return 'offline';
    }
  }
}
