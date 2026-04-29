import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants; // [buyerId, sellerId]
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final Map<String, dynamic> participantNames; // {userId: name}
  final Map<String, dynamic> participantAvatars; // {userId: avatar}
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.participantNames,
    required this.participantAvatars,
    this.unreadCount = 0,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json, String id) {
    return ChatModel(
      id: id,
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      participantNames: json['participantNames'] ?? {},
      participantAvatars: json['participantAvatars'] ?? {},
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'participants': participants,
    'lastMessage': lastMessage,
    'lastMessageTime': FieldValue.serverTimestamp(),
    'lastMessageSenderId': lastMessageSenderId,
    'participantNames': participantNames,
    'participantAvatars': participantAvatars,
    'unreadCount': unreadCount,
  };
}
