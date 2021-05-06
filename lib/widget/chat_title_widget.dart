import 'package:chat_demo/models/user_model.dart';
import 'package:flutter/material.dart';

enum UserOnlineStatus { online, offline, connecting }

class ChatTitle extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(chatUser.name),
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
    if (userOnlineStatus == UserOnlineStatus.connecting) {
      return 'connecting...';
    }
    if (userOnlineStatus == UserOnlineStatus.online) {
      return 'online';
    }
    if (userOnlineStatus == UserOnlineStatus.offline) {
      return 'offline';
    }
  }
}
