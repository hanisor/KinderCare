import 'package:kindercare/model/performance_model.dart';

import 'parent_model.dart';

class ChildModel {
  int? childId;
  final String childName;
  final String childDOB;
  final String childGender;
  final String childMykidNumber;
  final String childAllergies;
  final String childStatus;
  int? parentId;
  List<PerformanceModel> performances;
  ParentModel? guardian; // Add guardian field

  ChildModel({
    this.childId,
    required this.childName,
    required this.childDOB,
    required this.childGender,
    required this.childMykidNumber,
    required this.childAllergies,
    required this.childStatus,
    this.parentId,
    required this.performances,
    this.guardian,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    List<PerformanceModel> performances = [];

    if (json['performances'] != null && json['performances'] is List) {
      performances = (json['performances'] as List)
          .map((e) => PerformanceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ChildModel(
      childId: json['id'] as int?,
      childName: json['name'] as String? ?? '',
      childMykidNumber: json['my_kid_number'] as String? ?? '',
      childDOB: json['date_of_birth'] as String? ?? '',
      childGender: json['gender'] as String? ?? '',
      childAllergies: json['allergy'] as String? ?? '',
      childStatus: json['status'] as String? ?? '',
      parentId: json['guardian_id'] as int?,
      performances: performances.isNotEmpty ? performances : [],
      guardian: json['guardians'] != null
          ? ParentModel.fromJson(json['guardians'])
          : null, // Parse guardian
    );
  }

  factory ChildModel.fromAttendanceJson(Map<String, dynamic> json) {
    return ChildModel(
      childId: json['id'] as int?,
      childName: json['child_name'] as String? ?? '',
      childMykidNumber:
          '', // Assuming this is not provided in the attendance JSON
      childDOB: json['child_dob'] as String? ?? '',
      childGender: json['child_gender'] as String? ?? '',
      childAllergies: json['child_allergy'] as String? ?? '',
      childStatus: '', // Assuming this is not provided in the attendance JSON
      parentId: null, // Assuming this is not provided in the attendance JSON
      performances: [], // Assuming performances are not provided in the attendance JSON
    );
  }

  // Getters
  int? get getChildId => childId;
  String get getChildName => childName;
  String get getChildDOB => childDOB;
  String get getChildGender => childGender;
  String get getChildMykidNumber => childMykidNumber;
  String get getChildAllergies => childAllergies;
  String get getChildStatus => childStatus;
  int? get getParentId => parentId;
  List<PerformanceModel> get getPerformances => performances;

  // Setters
  set setChildId(int? newId) {
    childId = newId;
  }
}
