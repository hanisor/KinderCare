import 'package:kindercare/model/child_model.dart';

class CaregiverModel {
  final int id;
  final String caregiverName;
  final String caregiverPhoneNumber;
  final String caregiverICNumber;
  final String caregiverEmail;
  final String caregiverUsername;
  final String caregiverPassword;
  final String caregiverRole;
  final String caregiverStatus;
  List<ChildModel>? children;

  CaregiverModel({
    required this.id,
    required this.caregiverName,
    required this.caregiverPhoneNumber,
    required this.caregiverICNumber,
    required this.caregiverEmail,
    required this.caregiverUsername,
    required this.caregiverPassword,
    required this.caregiverRole,
    required this.caregiverStatus,
    this.children,
  });

  // Assuming ChildModel.fromJson exists
  factory CaregiverModel.fromJson(Map<String, dynamic> json) {
    var childrenJson = json['children'] as List?;
    List<ChildModel>? children = childrenJson?.map((child) => ChildModel.fromJson(child)).toList();

    return CaregiverModel(
      id: json['id'],
      caregiverName: json['name'],
      caregiverPhoneNumber: json['phone_number'],
      caregiverICNumber: json['ic_number'],
      caregiverEmail: json['email'],
      caregiverUsername: json['username'],
      caregiverPassword: json['password'],
      caregiverRole: json['role'],
      caregiverStatus: json['status'],
      children: children,
    );
  }
}
