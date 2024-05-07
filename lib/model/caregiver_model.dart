class caregiverModel {
  int? id;
  final String caregiverName;
  final String caregiverPhoneNumber;
  final String caregiverICNumber;
  final String caregiverEmail;
  final String caregiverUsername;
  final String caregiverPassword;
  final String caregiverStatus;

  caregiverModel({
    this.id,
    required this.caregiverName,
    required this.caregiverPhoneNumber,
    required this.caregiverICNumber,
    required this.caregiverEmail,
    required this.caregiverUsername,
    required this.caregiverPassword,
    required this.caregiverStatus,
  });
}
