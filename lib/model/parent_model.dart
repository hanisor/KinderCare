class ParentModel {
  int? id;
  final String parentName;
  final String parentPhoneNumber;
  final String parentICNumber;
  final String parentEmail;
  final String parentUsername;
  final String parentPassword;
  final String parentRole;
  final String parentStatus;

  ParentModel({
    this.id,
    required this.parentName,
    required this.parentPhoneNumber,
    required this.parentICNumber,
    required this.parentEmail,
    required this.parentUsername,
    required this.parentPassword,
    required this.parentRole,
    required this.parentStatus,
  });
}
