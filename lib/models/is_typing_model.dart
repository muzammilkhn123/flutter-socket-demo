import 'package:flutter/material.dart';

class IsTypingModel {
  int senderID;
  int receiverID;
  bool isTyping;
  IsTypingModel(
      {@required this.isTyping,
      @required this.senderID,
      @required this.receiverID});
  Map<String, dynamic> toJson() =>
      {"isTyping": isTyping, "senderID": senderID, "receiverID": receiverID};

  factory IsTypingModel.fromJson(Map<String, dynamic> json) => IsTypingModel(
      isTyping: json["isTyping"],
      senderID: json["senderID"],
      receiverID: json["receiverID"]);
}
