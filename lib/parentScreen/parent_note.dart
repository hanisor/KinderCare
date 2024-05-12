import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/note_model.dart';
import 'package:kindercare/request_controller.dart';

class ParentNote extends StatefulWidget {
  final int? parentId;
  ParentNote({Key? key, this.parentId});

  @override
  State<ParentNote> createState() => _ParentNoteState();
}

class _ParentNoteState extends State<ParentNote> {
  TextEditingController noteDetailsController = TextEditingController();
  String status = "UNREAD";
  String senderType = "parent";
  int caregiverId = 1;
  DateTime? dateTime;
  List<NoteModel> noteList = []; // List to hold checklist items

  @override
  void dispose() {
    noteDetailsController.dispose();
    super.dispose();
  }

  Future<void> sendNoteToAllCaregivers() async {
    String currentDateTime = DateTime.now().toString();
    print('Sending note to backend:');
    print('Note Details: ${noteDetailsController.text}');
    print('Date Time: $currentDateTime');
    print('Parent ID: ${widget.parentId}');
    print('Caregiver ID: $caregiverId');

    String formattedDateTime = DateFormat("yyyy-MM-dd HH:mm:ss")
        .format(DateTime.parse(currentDateTime));

    RequestController req = RequestController(path: 'guardian/add-note');

    req.setBody({
      "detail": noteDetailsController.text,
      "status": status,
      "sender_type": senderType,
      "date_time": formattedDateTime, // Convert DateTime to String
      "guardian_id": widget.parentId,
      "caregiver_id": caregiverId,
    });

    var response = await req.post();

    if (response.statusCode == 200) {
      var result = req.result();
      print('response = $result');
      if (result != null && result.containsKey('notes')) {
        print('Checklist item saved successfully');
        // Clear text field after successful submission
        //noteDetailsController.clear();
        fetchNotesByParentId(widget.parentId);
      } else {
        print('Error saving note item: ${response.statusCode}');
        print('Error message: ${response.body}');
      }
    }
  }

  Future<Map<String, dynamic>> getNoteByParentId(int? parentId) async {
    print('parentid : $parentId');
    RequestController req =
        RequestController(path: 'note/by-guardianId/$parentId');

    await req.get();
    var response = req.result();
    print("${req.status()}");
    if (req.status() == 200) {
      return response;
    } else {
      throw Exception('Failed to load parent details');
    }
  }

  Future<void> fetchNotesByParentId(int? parentId) async {
    RequestController req = RequestController(
        path: 'note/by-guardianId/$parentId'); // Pass email as parameter
    print("parentId : ${widget.parentId!}");
    await req.get();
    var response = req.result();
    if (response != null && response.containsKey('notes')) {
      var noteData = response['notes'];
      print("JSON Data: $noteData"); // Print JSON data for debugging
      setState(() {
        noteList = List<NoteModel>.from(noteData.map((x) {
          // Ensure noteId is parsed as an integer
          x['id'] = int.tryParse(x['id'].toString());
          print("noteId: ${x['id']}"); // Debug noteId
          print("noteStatus: ${x['status']}"); // Debug noteStatus
          return NoteModel.fromJson(x);
        }));

        // Filter notes with status "unread"
        noteList = noteList
            .where((note) =>
                note.noteStatus == 'UNREAD' &&
                DateTime.now().difference(note.noteDateTime).inDays <= 1)
            .toList();

        // Sort notes by date time (optional)
        noteList.sort((a, b) => a.noteDateTime.compareTo(b.noteDateTime));

        print("Updated noteList: $noteList"); // Print updated noteList

        print("Updated noteList: $noteList"); // Print updated noteList
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotesByParentId(widget.parentId!);
  }

  // // Method to delete a note
  // void deleteNoteAtIndex(int index) {
  //   setState(() {
  //     details.removeAt(index);
  //   });
  // }

  void refreshNotes() {
    fetchNotesByParentId(widget.parentId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshNotes,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Text field to enter note
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: noteDetailsController,
                    decoration: InputDecoration(labelText: 'Enter quick note'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    sendNoteToAllCaregivers();
                    noteDetailsController.clear(); // Clear the text field here
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
          // Display sent notes to all caregivers
          Expanded(
            child: ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                var note =
                    noteList.reversed.toList()[index]; // Reverse the list here
                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    // Handle note deletion
                    // deleteNoteAtIndex(index);
                  },
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                  ),
                  child: Card(
                    elevation: 4,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.noteDetails,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDateTime(note.noteDateTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  String _formatDateTime(DateTime dateTime) {
    String time = DateFormat.jm().format(dateTime); // Format time in 12-hour system
    String date = DateFormat.yMMMd().format(dateTime); // Format date
    return '$time, $date';
  }

}
