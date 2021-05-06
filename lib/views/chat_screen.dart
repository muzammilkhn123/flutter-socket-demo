import 'dart:async';
import 'dart:convert';

import 'package:chat_demo/Utils/global_values.dart';
import 'package:chat_demo/Utils/socket.dart';
import 'package:chat_demo/models/chat_message_model.dart';
import 'package:chat_demo/models/is_typing_model.dart';
import 'package:chat_demo/models/user_model.dart';
import 'package:chat_demo/widget/chat_title_widget.dart';
import 'package:chat_demo/widget/custom_painter.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _chatTextFieldController;
  List<ChatMessageModel> _chatMessagesList;
  UserOnlineStatus status;
  User _pairedUser;
  bool _isotherUserTyping = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _chatMessagesList = List();
    _pairedUser = GlobalValues.pairedWithUser;
    status = UserOnlineStatus.connecting;
    _chatTextFieldController = TextEditingController();
    initListners();
    _checkOnline();
  }

  initListners() {
    GlobalValues.socketUtils.onChatMessageReceiveListner(onMessageReceived);
    GlobalValues.socketUtils.setOnlineUserStatus(onUserStatus);
    GlobalValues.socketUtils.onTypingReceiveListner(onTypingReceived);
  }

  onUserStatus(data) {
    print("onUserStatus: $data");
    ChatMessageModel chatMessageModel =
        ChatMessageModel.fromJson(json.decode(data));

    status = chatMessageModel.toUserOnlineStatus
        ? UserOnlineStatus.online
        : UserOnlineStatus.offline;
    setState(() {
      status = chatMessageModel.toUserOnlineStatus
          ? UserOnlineStatus.online
          : UserOnlineStatus.offline;
    });
  }

  _checkOnline() {
    ChatMessageModel chatMessageModel = ChatMessageModel(
        chatId: 0,
        senderId: GlobalValues.loggedInUser.id,
        receiverId: _pairedUser.id,
        message: "",
        chatRoomType: SocketUtils.EVENT_SINGLE_CHAT_MESSAGE,
        toUserOnlineStatus: false);
    GlobalValues.socketUtils.checkOnline(chatMessageModel);
  }

  onMessageReceived(data) {
    print("OnMessageReceived: $data");
    ChatMessageModel chatMessageModel =
        ChatMessageModel.fromJson(json.decode(data));
    chatMessageModel.isFromMe = false;
    setState(() {
      _chatMessagesList.add(chatMessageModel);
    });
  }

  onTypingReceived(data) {
    print(data);
    IsTypingModel isTypingModel = IsTypingModel.fromJson(json.decode(data));
    if (isTypingModel.isTyping) {
      _isotherUserTyping = true;
    } else {
      _isotherUserTyping = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: ChatTitle(
          chatUser: _pairedUser,
          userOnlineStatus: status,
          isTyping: _isotherUserTyping,
        )),
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
                itemCount: _chatMessagesList.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 20,
                    margin: EdgeInsets.only(bottom: 10),
                    child: CustomPaint(
                        painter: CustomChatBubble(
                            color: _chatMessagesList[index].isFromMe
                                ? Colors.green[400]
                                : Colors.grey[300],
                            isOwn: _chatMessagesList[index].isFromMe),
                        child: Container(
                            width: 20,
                            padding: EdgeInsets.all(8),
                            child: Text(
                              _chatMessagesList[index].message,
                              textAlign: _chatMessagesList[index].isFromMe
                                  ? TextAlign.right
                                  : TextAlign.left,
                              style: TextStyle(
                                  color: _chatMessagesList[index].isFromMe
                                      ? Colors.white
                                      : Colors.black),
                            ))),
                  );
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
              sendMessageFunction();
            },
          ),
        ],
      ),
    );
  }

  sendMessageFunction() {
    print("Sending message to ${_pairedUser.name}, id:${_pairedUser.id} ");

    if (_chatTextFieldController.text.isNotEmpty) {
      ChatMessageModel chatMessageModel = ChatMessageModel(
          chatId: 0,
          senderId: GlobalValues.loggedInUser.id,
          receiverId: _pairedUser.id,
          message: _chatTextFieldController.text,
          chatRoomType: SocketUtils.EVENT_SINGLE_CHAT_MESSAGE,
          toUserOnlineStatus: false,
          isFromMe: true);
      GlobalValues.socketUtils.sendChatMessage(chatMessageModel);
      setState(() {
        _chatTextFieldController.text = "";
        _chatMessagesList.add(chatMessageModel);
      });
    }
  }

  _chatTextArea() {
    return Expanded(
      child: TextField(
        controller: _chatTextFieldController,
        onChanged: (value) {
          GlobalValues.socketUtils.sendIsTyping(
              isTyping: true,
              senderID: GlobalValues.loggedInUser.id,
              receiverID: _pairedUser.id);

          new Future.delayed(const Duration(seconds: 3), () {
            GlobalValues.socketUtils.sendIsTyping(
                isTyping: false,
                senderID: GlobalValues.loggedInUser.id,
                receiverID: _pairedUser.id);
          });
        },
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
