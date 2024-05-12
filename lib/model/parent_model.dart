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

  // Factory constructor to create a ChildModel from JSON
  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      id: json['id'] as int,
      parentName: json['name'] as String,
      parentPhoneNumber: json['phone_number'] as String,
      parentICNumber: json['ic_number'] as String,
      parentEmail: json['email'] as String,
      parentUsername: json['username'] as String,
      parentPassword: json['password'] as String,
      parentRole: json['role'] as String, 
      parentStatus: json['status'] as String,
    );
  }

  
   // Getters
  int? get getParentId => id;

  String get getParentName => parentName;

  String get getParentPhoneNumber => parentPhoneNumber;

  String get getParentICNumber => parentICNumber;

  String get getParentEmail => parentEmail;

  String get getParentUsername => parentUsername;

  String get getParentPassword => parentPassword;

  String get getParentRole => parentRole;

  String get getParentStatus => parentStatus;

  // Setters
  set setParentId(int? newId) {
    id = newId;
  }
}



  
