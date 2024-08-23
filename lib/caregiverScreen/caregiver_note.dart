import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/note_model.dart';
import 'package:kindercare/model/parent_model.dart';
import 'package:kindercare/request_controller.dart';

class CaregiverNote extends StatefulWidget {
  final int? caregiverId;
  CaregiverNote({Key? key, this.caregiverId});

  @override
  State<CaregiverNote> createState() => _CaregiverNoteState();
}

class _CaregiverNoteState extends State<CaregiverNote> with SingleTickerProviderStateMixin {
  TextEditingController noteDetailsController = TextEditingController();
  String status = "UNREAD";
  String senderType = "caregiver";
  DateTime? dateTime;
  List<NoteModel> noteList = []; // List to hold all notes
  List<NoteModel> filteredNoteList = []; // List to hold filtered notes by caregiver ID
  List<NoteModel> todayNotes = [];
  ParentModel? selectedParent;
  List<ParentModel> parentList = [];
  String? selectedMonth;
  int? selectedDay;

  late TabController _tabController;

  @override
  void dispose() {
    noteDetailsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> getGuardianData() async {
    RequestController req = RequestController(path: 'guardian-data');
    await req.get();
    var response = req.result();
    print("req result : $response"); // Print the response to see its type

    if (response != null && response is List) {
      setState(() {
        var parentData = response;
        print("Parent Data: $parentData"); // Debugging line
        parentList = parentData
            .map((x) => ParentModel(
                  id: x['id'] as int,
                  parentName: x['name'] as String,
                  parentPhoneNumber: x['phone_number'] as String,
                  parentICNumber: x['ic_number'] as String,
                  parentEmail: x['email'] as String,
                  parentUsername: x['username'] as String,
                  parentPassword: x['password'] as String?,
                  parentRole: x['role'] as String,
                  parentStatus: x['status'] as String,
                ))
            .toList();

        if (parentList.isNotEmpty) {
          selectedParent = parentList[0];
          fetchNotesByParentId(selectedParent!.id);
        }
      });
    } else {
      print("Failed to fetch parent data"); // Debugging line
    }
    print("[parentList] : $parentList");
  }

  Future<void> sendNoteTopParent() async {
    String currentDateTime = DateTime.now().toString();
    print('Sending note to backend:');
    print('Note Details: ${noteDetailsController.text}');
    print('Date Time: $currentDateTime');
    print('sender type: $senderType');
    print('Caregiver ID: ${widget.caregiverId}');
    print('parent ID: $selectedParent.id');

    String formattedDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(currentDateTime));

    RequestController req = RequestController(path: 'guardian/add-note');

    req.setBody({
      "detail": noteDetailsController.text,
      "status": status,
      "sender_type": senderType,
      "date_time": formattedDateTime, // Convert DateTime to String
      "guardian_id": selectedParent!.id.toString(),
      "caregiver_id": widget.caregiverId,
    });

    var response = await req.post();

    if (response.statusCode == 200) {
      var result = req.result();
      print('response = $result');
      if (result != null && result.containsKey('notes')) {
        print('Checklist item saved successfully');
        fetchNotesByParentId(selectedParent?.id);
      } else {
        print('Error saving note item: ${response.statusCode}');
        print('Error message: ${response.body}');
      }
    }
  }

  Future<void> fetchNotesByParentId(int? parentId) async {
    RequestController req = RequestController(path: 'note/by-guardianId/$parentId'); // Pass email as parameter
    print("parentId : ${selectedParent?.id}");
    await req.get();
    var response = req.result();
    if (response != null && response.containsKey('notes')) {
      var noteData = response['notes'];
      print("JSON Data: $noteData"); // Print JSON data for debugging
      setState(() {
        noteList = List<NoteModel>.from(noteData.map((x) {
          x['id'] = int.tryParse(x['id'].toString()); // Ensure noteId is parsed as an integer
          print("noteId: ${x['id']}"); // Debug noteId
          print("noteStatus: ${x['status']}"); // Debug noteStatus
          return NoteModel.fromJson(x);
        }));

        // Filter notes by caregiver ID
        filteredNoteList = noteList.where((note) {
          return note.caregiverId == widget.caregiverId;
        }).toList();

        // Filter today's notes
        DateTime today = DateTime.now();
        todayNotes = filteredNoteList.where((note) {
          return note.noteDateTime.year == today.year &&
              note.noteDateTime.month == today.month &&
              note.noteDateTime.day == today.day;
        }).toList();

        print("Updated noteList: $noteList"); // Print updated noteList
        print("Filtered Note List: $filteredNoteList"); // Print filtered notes list
        print("Today's Notes: $todayNotes"); // Print today's notes
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getGuardianData();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _refreshNotes() async {
    await fetchNotesByParentId(selectedParent?.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotes,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButton(
                hint: const Text(
                  "Select Parent Name",
                  style: TextStyle(
                    color: Colors.pink,
                  ),
                ),
                value: selectedParent,
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.pink,
                ),
                elevation: 4,
                style: const TextStyle(
                  color: Colors.pink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                underline: Container(
                  height: 2,
                  color: Colors.pink,
                ),
                items: parentList.map<DropdownMenuItem<ParentModel>>((parent) {
                  return DropdownMenuItem<ParentModel>(
                    value: parent,
                    child: Text(
                      parent.parentName,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedParent = value;
                    fetchNotesByParentId(selectedParent?.id);
                  });
                },
              ),
              if (selectedParent != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Ic Number: ${selectedParent!.parentICNumber}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Phone number: ${selectedParent!.parentPhoneNumber}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: noteDetailsController,
                      decoration: InputDecoration(
                        labelText: 'Enter quick note',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      sendNoteTopParent();
                      noteDetailsController.clear();
                    },
                    child: Text('Send'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Today\'s Notes'),
                  Tab(text: 'All Notes'),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNoteList(todayNotes),
                    _buildNoteList(filteredNoteList),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteList(List<NoteModel> notes) {
    return Container(
      padding: EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          var note = notes.reversed.toList()[index];
          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {},
            background: Container(
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16.0),
            ),
            child: Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.noteDetails,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDateTime(note.noteDateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          note.noteStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: note.noteStatus == "READ"
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    String time = DateFormat.jm().format(dateTime);
    String date = DateFormat.yMMMd().format(dateTime);
    return '$time, $date';
  }
}
