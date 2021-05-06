import 'dart:io';
import 'package:chat_demo/models/chat_message_model.dart';
import 'package:chat_demo/models/is_typing_model.dart';
import 'package:chat_demo/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketUtils {
  User _fromUser;

  static String _serverIP =
      Platform.isIOS ? "http://localhost" : "http://10.0.2.2";
  static const int SERVER_PORT = 3000;
  static String _url = "$_serverIP:$SERVER_PORT";
  static String _hrokuURL = "https://socket-server-trial.herokuapp.com";
  // Events
  static const String ON_MESSAGE_RECEIVED = 'receive_message';
  static const String SUB_EVENT_MESSAGE_SENT = 'message_sent_to_user';
  static const String IS_USER_CONNECTED_EVENT = 'is_user_connected';
  static const String IS_USER_ONLINE_EVENT = 'check_online';
  static const String SUB_EVENT_MESSAGE_FROM_SERVER = 'message_from_server';
  static const EVENT_SINGLE_CHAT_MESSAGE = "single_chat_message";
  static const EVENT_SEND_TYPING = "send_typing";
  static const EVENT_RECEIVED_TYPING = "received_typing";
  // Status
  static const int STATUS_MESSAGE_NOT_SENT = 10001;
  static const int STATUS_MESSAGE_SENT = 10002;
  static const int STATUS_MESSAGE_DELIVERED = 10003;
  static const int STATUS_MESSAGE_READ = 10004;

  initSocket(User fromUser) async {
    print('Connecting user: ${fromUser.id}');
    _fromUser = fromUser;
    await _init();
  }

  IO.Socket _socket;
  _init() async {
    if (_socket == null) {
      _socket = IO.io(_url, _socketOptions());
    } else {
      _socket.opts["query"] = "from=${_fromUser.id}";
    }
  }

  _socketOptions() {
    return new IO.OptionBuilder()
        .setTransports(['websocket'])
        .setQuery({"from": _fromUser.id})
        .disableAutoConnect()
        .build();
  }

  connectToSocket() {
    if (null == _socket) {
      print("Socket is Null");
      return;
    }
    print("Connecting to socket...");
    _socket.connect();
  }

  setConnectListener(Function onConnect) {
    _socket.onConnect((data) {
      onConnect(data);
    });
  }

  setOnConnectionErrorListener(Function onConnectError) {
    _socket.onConnectError((data) {
      onConnectError(data);
    });
  }

  setOnConnectionErrorTimeOutListener(Function onConnectTimeout) {
    _socket.onConnectTimeout((data) {
      onConnectTimeout(data);
    });
  }

  setOnErrorListener(Function onError) {
    _socket.onError((error) {
      onError(error);
    });
  }

  setOnDisconnectListener(Function onDisconnect) {
    _socket.onDisconnect((data) {
      print("onDisconnect $data");
      onDisconnect(data);
    });
  }

  closeConnection() {
    if (null != _socket) {
      print("Close Connection");
      _socket.io.disconnect();
    }
  }

  sendChatMessage(
    ChatMessageModel chatMessageModel,
  ) {
    if (_socket == null) {
      print("Cannot Send Message");
      return;
    }
    _socket.emit(EVENT_SINGLE_CHAT_MESSAGE, [chatMessageModel.toJson()]);
  }

  sendIsTyping(
      {@required bool isTyping,
      @required int senderID,
      @required int receiverID}) {
    if (_socket == null) {
      print("Cannot Send Message");
      return;
    }
    IsTypingModel isTypingModel = IsTypingModel(
        isTyping: isTyping, receiverID: receiverID, senderID: senderID);
    _socket.emit(EVENT_SEND_TYPING, [isTypingModel.toJson()]);
  }

  onChatMessageReceiveListner(Function onMessageReceived) {
    _socket.on(ON_MESSAGE_RECEIVED, (data) {
      onMessageReceived(data);
    });
  }

  onTypingReceiveListner(Function onTypingReceived) {
    _socket.on(EVENT_RECEIVED_TYPING, (data) {
      onTypingReceived(data);
    });
  }

  checkOnline(ChatMessageModel chatMessage) {
    print("Checking Online User: " + chatMessage.receiverId.toString());
    if (_socket == null) {
      print("Cannot Check Online");
      return;
    }
    _socket.emit(IS_USER_ONLINE_EVENT, [chatMessage.toJson()]);
  }

  setOnlineUserStatus(Function onUserStatus) {
    _socket.on(IS_USER_CONNECTED_EVENT, (data) {
      print(data);
      onUserStatus(data);
    });
  }
}
