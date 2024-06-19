class CaregiverModel {
  int id;
  final String caregiverName;
  final String caregiverPhoneNumber;
  final String caregiverICNumber;
  final String caregiverEmail;
  final String caregiverUsername;
  final String caregiverPassword;
  final String caregiverStatus;
  final String caregiverRole;

  CaregiverModel({
    required this.id,
    required this.caregiverName,
    required this.caregiverPhoneNumber,
    required this.caregiverICNumber,
    required this.caregiverEmail,
    required this.caregiverUsername,
    required this.caregiverPassword,
    required this.caregiverStatus,
    required this.caregiverRole,
  });

  factory CaregiverModel.fromJson(Map<String, dynamic> json) {
    return CaregiverModel(
      id: json['id'] ?? 0,  // Default to 0 if 'id' is null
      caregiverName: json['name'] ?? '',
      caregiverPhoneNumber: json['phone_number'] ?? '',
      caregiverICNumber: json['ic_number'] ?? '',
      caregiverEmail: json['email'] ?? '',
      caregiverUsername: json['username'] ?? '',
      caregiverPassword: json['password'] ?? '',
      caregiverRole: json['role'] ?? '',
      caregiverStatus: json['status'] ?? '',
    );
  }
}
