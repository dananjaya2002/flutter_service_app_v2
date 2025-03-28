import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      chatId: map['chatId'] as String,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
