
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/model/relative_model.dart';

class ChildRelativeModel {
  final int id;
  final int childId;
  final int relativeId;
  ChildModel? childModel; // Include ChildModel property
  RelativeModel? relativeModel; // Include ChildModel property

  ChildRelativeModel({
    required this.id,
    required this.childId,
    required this.relativeId,
    this.childModel,
    this.relativeModel,
  });

  factory ChildRelativeModel.fromJson(Map<String, dynamic> json) {
    return ChildRelativeModel(
      id: json['id'],
      childId: json['child_id'],
      relativeId: json['relative_id'],
      childModel: json['child'] != null ? ChildModel.fromJson(json['child']) : null, // Parse child data
      relativeModel: json['relative'] != null ? RelativeModel.fromJson(json['relative']) : null, // Parse relative data

    );
  }
}
