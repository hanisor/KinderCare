import 'package:flutter/src/material/list_tile.dart';

class ChildModel {
  int? childId; // Change type to int
  final String childName;
  int? childAge;
  final String childGender;
  final String childMykidNumber;
  final String childAllergies;
  int? parentId;

  ChildModel({
    this.childId,
    required this.childName,
    required this.childAge,
    required this.childGender,
    required this.childMykidNumber,
    required this.childAllergies,
    this.parentId,
  });

  // Factory constructor to create a ChildModel from JSON
  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      childId: json['id'] as int,
      childName: json['name'] as String,
      childMykidNumber: json['my_kid_number'] as String,
      childAge: json['age'] as int,
      childGender: json['gender'] as String,
      childAllergies: json['allergy'] as String,
      parentId: json['guardian_id'] as int,
    );
  }

  // Getters
  int? get getChildId => childId;

  String get getChildName => childName;

  int? get getChildAge => childAge;

  String get getChildGender => childGender;

  String get getChildMykidNumber => childMykidNumber;

  String get getChildAllergies => childAllergies;

  int? get getParentId => parentId;

  // Setters
  set setChildId(int? newId) {
    childId = newId;
  }

  map(ListTile Function(dynamic child) param0) {}
// You can create setters for other fields in a similar manner if needed
}
