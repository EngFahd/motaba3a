import 'package:cloud_firestore/cloud_firestore.dart';

/// User types in the system
enum UserType { workshop, client }

/// Represents a user in the Motaba3a system
/// Can be either a workshop owner or a client
class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final String? email;
  final UserType userType;
  final String? workshopName; // Only for workshop users
  final String? unifiedNumber; // Only for workshop users (registration number)
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.userType,
    this.workshopName,
    this.unifiedNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      userType: UserType.values.firstWhere(
        (e) => e.toString() == 'UserType.${map['userType']}',
        orElse: () => UserType.client,
      ),
      workshopName: map['workshopName'],
      unifiedNumber: map['unifiedNumber'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert UserModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'userType': userType.toString().split('.').last,
      'workshopName': workshopName,
      'unifiedNumber': unifiedNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? name,
    String? phoneNumber,
    String? email,
    UserType? userType,
    String? workshopName,
    String? unifiedNumber,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      workshopName: workshopName ?? this.workshopName,
      unifiedNumber: unifiedNumber ?? this.unifiedNumber,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

