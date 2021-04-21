import 'package:flutter/material.dart';

class User {
  final int id;
  final String name, email;

  User({@required this.email, @required this.name, @required this.id});
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
      };
}
