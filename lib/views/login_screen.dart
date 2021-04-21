import 'package:chat_demo/Utils/global_values.dart';
import 'package:chat_demo/models/user_model.dart';
import 'package:chat_demo/views/users_list_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController;
  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    GlobalValues.initDummyUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Let's Chat"),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(20.0),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            OutlineButton(child: Text('LOGIN'), onPressed: _loginButtonTap)
          ],
        ),
      ),
    );
  }

  _loginButtonTap() {
    if (_usernameController.text.isNotEmpty) {
      User currentUser = GlobalValues.dummyUsers[0];
      if (_usernameController.text != "a") {
        currentUser = GlobalValues.dummyUsers[1];
      }
      GlobalValues.loggedInUser = currentUser;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UsersListScreen()));
    }
  }
}
