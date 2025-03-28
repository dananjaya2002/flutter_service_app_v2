import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String shopId;
  final String customerId;
  final String serviceProviderId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isRead;
  final Map<String, dynamic> participants;

  ChatModel({
    required this.id,
    required this.shopId,
    required this.customerId,
    required this.serviceProviderId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isRead,
    required this.participants,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] as String,
      shopId: map['shopId'] as String,
      customerId: map['customerId'] as String,
      serviceProviderId: map['serviceProviderId'] as String,
      lastMessage: map['lastMessage'] as String,
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      isRead: map['isRead'] as bool,
      participants: map['participants'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'customerId': customerId,
      'serviceProviderId': serviceProviderId,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'isRead': isRead,
      'participants': participants,
    };
  }

  ChatModel copyWith({
    String? id,
    String? shopId,
    String? customerId,
    String? serviceProviderId,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isRead,
    Map<String, dynamic>? participants,
  }) {
    return ChatModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      customerId: customerId ?? this.customerId,
      serviceProviderId: serviceProviderId ?? this.serviceProviderId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isRead: isRead ?? this.isRead,
      participants: participants ?? this.participants,
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final bool isRead;
  final String? imageUrl;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }
}
