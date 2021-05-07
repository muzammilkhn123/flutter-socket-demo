import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_demo/Utils/global_values.dart';
import 'package:chat_demo/Utils/socket.dart';
import 'package:chat_demo/models/chat_message_model.dart';
import 'package:chat_demo/models/is_typing_model.dart';
import 'package:chat_demo/models/user_model.dart';
import 'package:chat_demo/widget/chat_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_3.dart';
import 'package:image_picker/image_picker.dart';

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
        toUserOnlineStatus: false,
        isPicture: false);
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
    ChatTitleState.isTyping = _isotherUserTyping;
    chatTitleState.setState(() {});
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
                padding: EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
                itemCount: _chatMessagesList.length,
                itemBuilder: (context, index) {
                  if (!_chatMessagesList[index].isPicture) {
                    return ChatBubble(
                      clipper: ChatBubbleClipper3(
                          type: _chatMessagesList[index].isFromMe
                              ? BubbleType.sendBubble
                              : BubbleType.receiverBubble),
                      alignment: _chatMessagesList[index].isFromMe
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      margin: EdgeInsets.only(top: 20),
                      backGroundColor: _chatMessagesList[index].isFromMe
                          ? Colors.green[400]
                          : Color(0xffE7E7ED),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.5,
                        ),
                        child: Text(
                          _chatMessagesList[index].message,
                          style: TextStyle(
                              color: _chatMessagesList[index].isFromMe
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    );
                  } else {
                    const Base64Codec base64 = Base64Codec();
                    if (_chatMessagesList[index].message == null)
                      return new Container();
                    final bytes =
                        base64.decode(_chatMessagesList[index].message);

                    return ChatBubble(
                        clipper: ChatBubbleClipper3(
                            type: _chatMessagesList[index].isFromMe
                                ? BubbleType.sendBubble
                                : BubbleType.receiverBubble),
                        alignment: _chatMessagesList[index].isFromMe
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        margin: EdgeInsets.only(top: 20),
                        backGroundColor: _chatMessagesList[index].isFromMe
                            ? Colors.green[400]
                            : Color(0xffE7E7ED),
                        child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            child: Image.memory(bytes, height: 200)));
                  }
                })));
  }

  _bottomChatArea() {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Row(children: <Widget>[
          _chatTextArea(),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              sendMessageFunction();
            },
          ),
          IconButton(
              icon: Icon(Icons.add_photo_alternate),
              onPressed: () {
                _showPicker();
                print("ancd");
              })
        ]));
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
          isPicture: false,
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

  _imgFromCamera() async {
    PickedFile image = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 50);

    File selected = File(image.path);

    if (selected != null) {
      List<int> imageBytes = selected.readAsBytesSync();
      print(imageBytes);
      String base64Image = base64Encode(imageBytes);
      ChatMessageModel chatMessageModel = ChatMessageModel(
          chatId: 0,
          senderId: GlobalValues.loggedInUser.id,
          receiverId: _pairedUser.id,
          message: base64Image,
          chatRoomType: SocketUtils.EVENT_SINGLE_CHAT_MESSAGE,
          toUserOnlineStatus: false,
          isPicture: true,
          isFromMe: true);

      GlobalValues.socketUtils.sendChatMessage(chatMessageModel);
      setState(() {
        _chatMessagesList.add(chatMessageModel);
      });
    }
  }

  _imgFromGallery() async {
    PickedFile image = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);
    File selected = File(image.path);
    if (selected != null) {
      List<int> imageBytes = selected.readAsBytesSync();
      print(imageBytes);
      String base64Image = base64Encode(imageBytes);
      ChatMessageModel chatMessageModel = ChatMessageModel(
          chatId: 0,
          senderId: GlobalValues.loggedInUser.id,
          receiverId: _pairedUser.id,
          message: base64Image,
          chatRoomType: SocketUtils.EVENT_SINGLE_CHAT_MESSAGE,
          toUserOnlineStatus: false,
          isPicture: true,
          isFromMe: true);

      GlobalValues.socketUtils.sendChatMessage(chatMessageModel);
      setState(() {
        _chatMessagesList.add(chatMessageModel);
      });
    }
  }

  void _showPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
