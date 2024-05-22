import 'package:flutter/material.dart';
import 'package:kindercare/model/performance_model.dart';

class ChildModel {
  int? childId; // Change type to int
  final String childName;
  final String childDOB;
  final String childGender;
  final String childMykidNumber;
  final String childAllergies;
  int? parentId;
  List<PerformanceModel> performances; // Add this line

  ChildModel({
    this.childId,
    required this.childName,
    required this.childDOB,
    required this.childGender,
    required this.childMykidNumber,
    required this.childAllergies,
    this.parentId,
    required this.performances, // Add this line
  });

  // Factory constructor to create a ChildModel from JSON
  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      childId: json['id'] as int,
      childName: json['name'] as String,
      childMykidNumber: json['my_kid_number'] as String,
      childDOB: json['date_of_birth'] as String,
      childGender: json['gender'] as String,
      childAllergies: json['allergy'] as String,
      parentId: json['guardian_id'] as int,
      performances: (json['performances'] as List<dynamic>)
          .map((e) => PerformanceModel.fromJson(e as Map<String, dynamic>))
          .toList(), // Add this line
    );
  }

  // Getters
  int? get getChildId => childId;
  String get getChildName => childName;
  String get getChildDOB => childDOB;
  String get getChildGender => childGender;
  String get getChildMykidNumber => childMykidNumber;
  String get getChildAllergies => childAllergies;
  int? get getParentId => parentId;
  List<PerformanceModel> get getPerformances => performances; // Add this line

  // Setters
  set setChildId(int? newId) {
    childId = newId;
  }

  map(ListTile Function(dynamic child) param0) {}
}
