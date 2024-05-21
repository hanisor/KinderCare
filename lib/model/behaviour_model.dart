import 'child_model.dart';

class BehaviourModel {
  int? id;
  String type;
  final String description;
  final String dateTime;
  int? childId;
  ChildModel? childModel;
  String? _childName; // Add childName property

  // Getter for childName
  String? get childName => _childName;

  // Setter for childName
  set childName(String? value) {
    _childName = value;
  }

  BehaviourModel({
    this.id,
    required this.type,
    required this.description,
    required this.dateTime,
    this.childId,
    this.childModel,
  });

  factory BehaviourModel.fromJson(Map<String, dynamic> json) {
    return BehaviourModel(
      id: json['id'],
      type: json['type'],
      description: json['dosage'],
      dateTime: json['date_time'],
      childId: json['child_id'],
      childModel: json['child'] != null ? ChildModel.fromJson(json['child']) : null,
    );
  }
}
