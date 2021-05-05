import 'dart:convert';

ChatMessageModel chatMessageModelFromJson(String str) =>
    ChatMessageModel.fromJson(json.decode(str));

String chatMessageModelToJson(ChatMessageModel data) =>
    json.encode(data.toJson());

class ChatMessageModel {
  ChatMessageModel(
      {this.chatId,
      this.senderId,
      this.receiverId,
      this.message,
      this.chatRoomType,
      this.toUserOnlineStatus,
      this.isFromMe });

  int chatId;
  int senderId;
  int receiverId;
  String message;
  String chatRoomType;
  bool toUserOnlineStatus;
  bool isFromMe;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        chatId: json["chatID"],
        senderId: json["senderID"],
        receiverId: json["ReceiverID"],
        message: json["message"],
        chatRoomType: json["chatRoomType"],
        toUserOnlineStatus: json["to_user_online_status"],
      );

  Map<String, dynamic> toJson() => {
        "chatID": chatId,
        "senderID": senderId,
        "ReceiverID": receiverId,
        "message": message,
        "chatRoomType": chatRoomType,
        "to_user_online_status": toUserOnlineStatus,
      };
}
