import 'child_model.dart';

class BehaviourModel {
  int? id;
  String type;
  final String description;
  final String dateTime;
  int? childId;
  ChildModel? childModel;
  String? _childName;

  // Getter for childName
  String? get childName => _childName ?? childModel?.childName;

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

  factory BehaviourModel.fromJson(Map<String, dynamic> json, {ChildModel? childModel}) {
    return BehaviourModel(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      dateTime: json['date_time'],
      childId: json['child_id'],
      childModel: childModel,
    );
  }
}
