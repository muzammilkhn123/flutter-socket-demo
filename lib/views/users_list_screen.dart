import 'package:chat_demo/Utils/global_values.dart';
import 'package:chat_demo/models/user_model.dart';
import 'package:chat_demo/views/chat_screen.dart';
import 'package:flutter/material.dart';

class UsersListScreen extends StatefulWidget {
  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  List<User> usersForChat;
  bool _isSocketConnected;
  String _connectMessage;
  @override
  void initState() {
    super.initState();

    _isSocketConnected = false;
    _connectMessage = "Connecting...";
    usersForChat = GlobalValues.getUsersForChat(GlobalValues.loggedInUser);
    _connectToSocket();
  }

  _connectToSocket() async {
    Future.delayed(Duration(seconds: 2), () async {
      print(
          "Connecting Logged In User: ${GlobalValues.loggedInUser.name}, ID: ${GlobalValues.loggedInUser.id}");
      GlobalValues.initSocket();
      await GlobalValues.socketUtils.initSocket(GlobalValues.loggedInUser);
      GlobalValues.socketUtils.connectToSocket();
      GlobalValues.socketUtils.setConnectListener(onConnect);
      GlobalValues.socketUtils.setOnDisconnectListener(onDisconnect);
      GlobalValues.socketUtils.setOnErrorListener(onError);
      GlobalValues.socketUtils.setOnConnectionErrorListener(onConnectError);
    });
  }

  onConnect(data) {
    print('Connected $data');
    if (mounted) {
      setState(() {
        _isSocketConnected = true;
      });
    }
  }

  onConnectError(data) {
    print('onConnectError $data');
    setState(() {
      _isSocketConnected = false;
      _connectMessage = 'Failed to Connect';
    });
  }

  onConnectTimeout(data) {
    print('onConnectTimeout $data');
    setState(() {
      _isSocketConnected = false;
      _connectMessage = 'Connection timedout';
    });
  }

  onError(data) {
    print('onError $data');
    setState(() {
      _isSocketConnected = false;
      _connectMessage = 'Connection Failed';
    });
  }

  onDisconnect(data) {
    print('onDisconnect $data');
    if (mounted) {
      setState(() {
        _isSocketConnected = false;
        _connectMessage = 'Disconnected';
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Users List'),
          leading: Container(),
          actions: [
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  GlobalValues.socketUtils.closeConnection();
                })
          ],
        ),
        body: Container(
            color: Colors.white,
            alignment: Alignment.center,
            padding: EdgeInsets.all(30.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text(_isSocketConnected ? 'Connected' : _connectMessage),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: usersForChat.length,
                      itemBuilder: (_, index) {
                        User user = usersForChat[index];
                        return GestureDetector(
                            onTap: () {
                              GlobalValues.pairedWithUser = user;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen()));
                            },
                            child: ListTile(
                                title: Text(user.name),
                                subtitle:
                                    Text('ID: ${user.id}, ${user.email}')));
                      }))
            ])));
  }
}
