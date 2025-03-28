import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequestModel {
  final String id;
  final String shopId;
  final String customerId;
  final String serviceProviderId;
  final String status; // pending, accepted, rejected, completed
  final String? serviceDescription;
  final Timestamp createdAt;
  final Timestamp? completedAt;

  ServiceRequestModel({
    required this.id,
    required this.shopId,
    required this.customerId,
    required this.serviceProviderId,
    required this.status,
    this.serviceDescription,
    required this.createdAt,
    this.completedAt,
  });

  factory ServiceRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceRequestModel(
      id: id,
      shopId: map['shopId'] ?? '',
      customerId: map['customerId'] ?? '',
      serviceProviderId: map['serviceProviderId'] ?? '',
      status: map['status'] ?? 'pending',
      serviceDescription: map['serviceDescription'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      completedAt: map['completedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'customerId': customerId,
      'serviceProviderId': serviceProviderId,
      'status': status,
      'serviceDescription': serviceDescription,
      'createdAt': createdAt,
      'completedAt': completedAt,
    };
  }

  ServiceRequestModel copyWith({String? status, Timestamp? completedAt}) {
    return ServiceRequestModel(
      id: id,
      shopId: shopId,
      customerId: customerId,
      serviceProviderId: serviceProviderId,
      status: status ?? this.status,
      serviceDescription: serviceDescription,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
