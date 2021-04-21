import 'package:chat_demo/Utils/socket.dart';
import 'package:chat_demo/models/user_model.dart';

class GlobalValues {
  static List<User> dummyUsers = List();
  static User loggedInUser;
  static User pairedWithUser;

  static SocketUtils socketUtils;

  static void initDummyUsers() {
    User userA = User(id: 1, email: 'a@a.com', name: "A");
    User userB = User(id: 2, email: 'b@b.com', name: "B");
    User userC = User(id: 3, email: 'c@c.com', name: "C");
    dummyUsers.add(userA);
    dummyUsers.add(userB);
    dummyUsers.add(userC);
  }

  static List<User> getUsersForChat(User user) {
    List<User> filteredUsers = dummyUsers
        .where((u) => (!u.name.toLowerCase().contains(user.name.toLowerCase())))
        .toList();
    return filteredUsers;
  }

  static initSocket() {
    if (socketUtils == null) {
      socketUtils = SocketUtils();
    }
    
  }
}
