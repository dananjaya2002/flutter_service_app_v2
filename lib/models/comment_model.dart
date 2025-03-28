import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String shopId;
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final Timestamp timestamp;

  CommentModel({
    required this.id,
    required this.shopId,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.timestamp,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      shopId: map['shopId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      comment: map['comment'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'rating': rating,
      'timestamp': timestamp,
    };
  }
}
