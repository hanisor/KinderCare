class SicknessModel {
  int? sicknessId;
  final String sicknessType;
  final String dosage;
  final String dateTime;
  final String sicknessStatus;
  int? childId;
  bool isChecked; // Add isChecked property


  SicknessModel({
    this.sicknessId,
    required this.sicknessType,
    required this.dosage,
    required this.dateTime,
    required this.sicknessStatus,
    this.childId,
    this.isChecked = false, // Initialize isChecked to false
  });

  factory SicknessModel.fromJson(Map<String, dynamic> json) {
    return SicknessModel(
      sicknessId: json['id'],
      sicknessType: json['type'],
      dosage: json['dosage'],
      dateTime: json['date_time'],
      childId: json['child_id'],
      sicknessStatus: json['status'],
    );
  }

  // Getter for sicknessId
  int? get getSicknessId => sicknessId;

  // Setter for sicknessId
  set setSicknessId(int? id) {
    sicknessId = id;
  }

  // Getter for sicknessType
  String get getSicknessType => sicknessType;

  // Getter for dosage
  String get getDosage => dosage;

  // Getter for dateTime
  String get getDateTime => dateTime;

  // Getter for childId
  int? get getChildId => childId;
}
