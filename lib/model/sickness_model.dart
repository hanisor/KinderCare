import 'child_model.dart';

class SicknessModel {
  int? sicknessId;
  String sicknessType;
  final String dosage;
  final String dateTime;
  String sicknessStatus;
  int? childId;
  bool isChecked; // Add isChecked property
  ChildModel? childModel; // Include ChildModel property

  SicknessModel({
    this.sicknessId,
    required this.sicknessType,
    required this.dosage,
    required this.dateTime,
    required this.sicknessStatus,
    this.childId,
    this.isChecked = false, // Initialize isChecked to false
    this.childModel,
  });

  factory SicknessModel.fromJson(Map<String, dynamic> json) {
    return SicknessModel(
      sicknessId: json['id'],
      sicknessType: json['type'],
      dosage: json['dosage'],
      dateTime: json['date_time'],
      sicknessStatus: json['status'],
      childId: json['child_id'],
      childModel: json['child'] != null ? ChildModel.fromJson(json['child']) : null, // Parse child data
    );
  }
}
