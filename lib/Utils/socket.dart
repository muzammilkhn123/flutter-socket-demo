import 'dart:io';
import 'package:chat_demo/models/user_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketUtils {
  User _fromUser;

  static String _serverIP =
      Platform.isIOS ? "http://localhost" : "http://10.0.2.2";
  static const int SERVER_PORT = 3000;
  static String _url = "$_serverIP:$SERVER_PORT";

  // Events
  static const String ON_MESSAGE_RECEIVED = 'receive_message';
  static const String SUB_EVENT_MESSAGE_SENT = 'message_sent_to_user';
  static const String IS_USER_CONNECTED_EVENT = 'is_user_connected';
  static const String IS_USER_ONLINE_EVENT = 'check_online';
  static const String SUB_EVENT_MESSAGE_FROM_SERVER = 'message_from_server';

  // Status
  static const int STATUS_MESSAGE_NOT_SENT = 10001;
  static const int STATUS_MESSAGE_SENT = 10002;
  static const int STATUS_MESSAGE_DELIVERED = 10003;
  static const int STATUS_MESSAGE_READ = 10004;

  initSocket(User fromUser) async {
    print('Connecting user: ${fromUser.name}');
    this._fromUser = fromUser;
    await _init();
  }

  IO.Socket _socket;
  _init() async {
    _socket = IO.io(_url, _socketOptions());
  }

  _socketOptions() {
    final Map<String, String> userMap = {
      'from': _fromUser.id.toString(),
    };
    return IO.OptionBuilder()
        .setTransports(['websocket'])
        .setQuery(userMap)
        .build(); // for Flutter or Dart VM
    // _connectUrl,
    // enableLogging: true,
    // transports: [Transports.WEB_SOCKET],
    // query: userMap,
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
}
