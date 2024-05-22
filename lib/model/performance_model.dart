import 'child_model.dart';

class PerformanceModel {
  int? id;
  String skill;
  final String level;
  final String date;
  int? childId;
  ChildModel? childModel;
  String? _childName; // Add childName property

  // Getter for childName
  String? get childName => _childName;

  // Setter for childName
  set childName(String? value) {
    _childName = value;
  }

  PerformanceModel({
    this.id,
    required this.skill,
    required this.level,
    required this.date,
    this.childId,
    this.childModel,
  });

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      id: json['id'],
      skill: json['skill'] as String? ?? 'Unknown Skill',
      level: json['level'] as String? ?? 'Unknown level',
      date: json['date'] as String? ?? 'Unknown date',
      childId: json['child_id'],
      childModel: json['child'] != null ? ChildModel.fromJson(json['child']) : null,
    );
  }
}
