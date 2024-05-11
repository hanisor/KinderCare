class RelativeModel {
  int? relativeId;
  final String name;
  final String relation;
  final String phone_number;
  final String dateTime;
  final String status;
  int? parentId;

  RelativeModel({
    this.relativeId,
    required this.name,
    required this.relation,
    required this.phone_number,
    required this.dateTime,
    required this.status,
    this.parentId,
  });

  factory RelativeModel.fromJson(Map<String, dynamic> json) {
    return RelativeModel(
      relativeId: json['id'],
      name: json['name'],
      relation: json['relation'],
      phone_number: json['phone_number'],
      dateTime: json['date_time'],
      status: json['status'],
      parentId: json['guardian_id'],
    );
  }

  // Getter for relativeId
  int? get getRelativeId => relativeId;

  // Setter for relativeId
  set getRelativeId(int? id) {
    relativeId = id;
  }

  // Getter for relativeName
  String get getRelativeName => name;

  // Getter for phone number
  String get getPhoneNumber => phone_number;

  // Getter for dateTime
  String get getDateTime => dateTime;

  String get getStatus => status;

  // Getter for parentId
  int? get getParentId => parentId;
}
