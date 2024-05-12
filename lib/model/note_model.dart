import 'caregiver_model.dart';
import 'parent_model.dart';

class NoteModel {
  int? noteId;
  final String noteDetails;
  final DateTime noteDateTime;
  String noteStatus;
  final String senderType;
  int? parentId;
  int? caregiverId;
  ParentModel? parentModel; // Include ChildModel property
  CaregiverModel? caregiverModel; // Include ChildModel property


  NoteModel({
    this.noteId,
    required this.noteDetails,
    required this.noteDateTime,
    required this.noteStatus,
    required this.senderType,
    required this.parentId,
    required this.caregiverId,
    this.parentModel,
    this.caregiverModel,

  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      noteId: json['id'],
      noteDetails: json['detail'] ?? '',
      noteDateTime:
          DateTime.parse(json['date_time']), // Convert string to DateTime
      noteStatus: json['status'] ?? '',
      senderType: json['sender_type'] ?? '',
      parentId: json['guardian_id'],
      caregiverId: json['caregiver_id'],
      parentModel: json['guardian'] != null ? ParentModel.fromJson(json['guardian']) : null, // Parse child data
      caregiverModel: json['caregiver'] != null ? CaregiverModel.fromJson(json['caregiver']) : null, // Parse child data

    );
  }

  // Getter for noteId
  int? get getNoteId => noteId;

  // Setter for noteId
  set setNoteId(int? value) {
    noteId = value;
  }
}
