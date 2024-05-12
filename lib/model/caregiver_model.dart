class CaregiverModel {
  int? id;
  final String caregiverName;
  final String caregiverPhoneNumber;
  final String caregiverICNumber;
  final String caregiverEmail;
  final String caregiverUsername;
  final String caregiverPassword;
  final String caregiverStatus;
  final String caregiverRole;

  CaregiverModel({
    this.id,
    required this.caregiverName,
    required this.caregiverPhoneNumber,
    required this.caregiverICNumber,
    required this.caregiverEmail,
    required this.caregiverUsername,
    required this.caregiverPassword,
    required this.caregiverStatus,
    required this.caregiverRole
  });

  // Factory constructor to create a ChildModel from JSON
  factory CaregiverModel.fromJson(Map<String, dynamic> json) {
    return CaregiverModel(
      id: json['id'] as int,
      caregiverName: json['name'] as String,
      caregiverPhoneNumber: json['phone_number'] as String,
      caregiverICNumber: json['ic_number'] as String,
      caregiverEmail: json['email'] as String,
      caregiverUsername: json['username'] as String,
      caregiverPassword: json['password'] as String,
      caregiverRole: json['role'] as String,
      caregiverStatus: json['status'] as String,
    );
  }
}
