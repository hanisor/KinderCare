class NoteModel {
  int? noteId;
  final String noteDetails;
  final DateTime noteDateTime;
  final String noteStatus;
  int? parentId;
  int? caregiverId;

  NoteModel({
    this.noteId,
    required this.noteDetails,
    required this.noteDateTime,
    required this.noteStatus,
    required this.parentId,
    required this.caregiverId,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      noteId: json['id'],
      noteDetails: json['detail'] ?? '',
      noteDateTime: DateTime.parse(json['date_time']), // Convert string to DateTime
      noteStatus: json['status'] ?? '',
      parentId: json['guardian_id'],
      caregiverId: json['caregiver_id'],
    );
  }


  // Getter for noteId
  int? get getNoteId => noteId;

  // Setter for noteId
  set setNoteId(int? value) {
    noteId = value;
  }
}
