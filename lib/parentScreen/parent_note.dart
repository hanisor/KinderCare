import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/caregiver_model.dart';
import 'package:kindercare/model/note_model.dart';
import 'package:kindercare/request_controller.dart';

class ParentNote extends StatefulWidget {
  final int? parentId;
  ParentNote({Key? key, this.parentId});

  @override
  State<ParentNote> createState() => _ParentNoteState();
}

class _ParentNoteState extends State<ParentNote> with SingleTickerProviderStateMixin {
  TextEditingController noteDetailsController = TextEditingController();
  String status = "UNREAD";
  String senderType = "parent";
  DateTime? dateTime;
  List<NoteModel> noteList = [];
  List<NoteModel> todayNotes = [];
  List<NoteModel> allNotes = [];
  CaregiverModel? selectedCaregiver;
  List<CaregiverModel> caregiverList = [];
  String? selectedMonth;
  int? selectedDay;

  late TabController _tabController;

  @override
  void dispose() {
    noteDetailsController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> getCaregiverData() async {
  String path = 'get-caregiver/${widget.parentId}';
  RequestController req = RequestController(path: path);

  await req.get(); // Use get method as usual
  var response = req.result();
  print("req result : $response");

  if (response != null && response is Map && response.containsKey('caregivers')) {
    var caregivers = response['caregivers'] as List;
    setState(() {
      caregiverList = caregivers
          .map((x) => CaregiverModel(
                id: x['id'] as int,
                caregiverName: x['name'] as String,
                caregiverPhoneNumber: x['phone_number'] as String,
                caregiverICNumber: x['ic_number'] as String,
                caregiverEmail: x['email'] as String,
                caregiverUsername: x['username'] as String,
                caregiverPassword: x['password'] as String?,
                caregiverRole: x['role'] as String,
                caregiverStatus: x['status'] as String,
              ))
          .toList();

      if (caregiverList.isNotEmpty) {
        selectedCaregiver = caregiverList[0];
        fetchNotesBycaregiverId(selectedCaregiver!.id);
      }
    });
  } else {
    print("Failed to fetch caregiver data");
  }
}


  Future<void> sendNoteToAllCaregivers() async {
    String currentDateTime = DateTime.now().toString();
    print('Sending note to backend:');
    print('Note Details: ${noteDetailsController.text}');
    print('Date Time: $currentDateTime');
    print('Parent ID: ${widget.parentId}');
    print('Caregiver ID: ${selectedCaregiver?.id}');

    String formattedDateTime = DateFormat("yyyy-MM-dd HH:mm:ss")
        .format(DateTime.parse(currentDateTime));

    RequestController req = RequestController(path: 'guardian/add-note');

    req.setBody({
      "detail": noteDetailsController.text,
      "status": status,
      "sender_type": senderType,
      "date_time": formattedDateTime,
      "guardian_id": widget.parentId,
      "caregiver_id": selectedCaregiver!.id.toString(),
    });

    var response = await req.post();

    if (response.statusCode == 200) {
      var result = req.result();
      print('response = $result');
      if (result != null && result.containsKey('notes')) {
        print('Checklist item saved successfully');
        fetchNotesBycaregiverId(widget.parentId);
      } else {
        print('Error saving note item: ${response.statusCode}');
        print('Error message: ${response.body}');
      }
    }
  }

  Future<Map<String, dynamic>> getNoteBycaregiverId(int? parentId) async {
    print('parentid : $parentId');
    RequestController req =
        RequestController(path: 'note/by-caregiverId/$parentId');

    await req.get();
    var response = req.result();
    print("${req.status()}");
    if (req.status() == 200) {
      return response;
    } else {
      throw Exception('Failed to load parent details');
    }
  }

Future<void> fetchNotesBycaregiverId(int? caregiverId) async {
  RequestController req = RequestController(path: 'note/by-caregiverId/$caregiverId');
  print("caregiver id: ${caregiverId}");

  await req.get();
  var response = req.result();

  if (response != null && response.containsKey('notes')) {
    var noteData = response['notes'];
    print("JSON Data: $noteData");

    setState(() {
      // Convert JSON data to NoteModel instances
      noteList = List<NoteModel>.from(noteData.map((x) {
        x['id'] = int.tryParse(x['id'].toString());
        print("noteId: ${x['id']}");
        print("noteStatus: ${x['status']}");
        return NoteModel.fromJson(x);
      }));

      // Filter notes by parentId
      noteList = noteList.where((note) => note.parentId == widget.parentId).toList();

      // Get today's notes with senderType 'parent' only
      DateTime now = DateTime.now();
      todayNotes = noteList.where((note) {
        return note.noteDateTime.year == now.year &&
            note.noteDateTime.month == now.month &&
            note.noteDateTime.day == now.day &&
            note.senderType == 'parent';
      }).toList();

      // Filter all notes by sender type
      allNotes = noteList.where((note) => note.senderType == 'parent').toList();

      // Sort notes
      noteList.sort((a, b) => b.noteDateTime.compareTo(a.noteDateTime));
      todayNotes.sort((a, b) => b.noteDateTime.compareTo(a.noteDateTime));
      allNotes.sort((a, b) => b.noteDateTime.compareTo(a.noteDateTime));

      print("Updated noteList: $noteList");
    });
  } else {
    print("Failed to fetch notes data");
  }
}



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getCaregiverData();
  }

  Future<void> _refreshNotes() async {
    await fetchNotesBycaregiverId(selectedCaregiver?.id);
  }

  List<NoteModel> getFilteredNotes() {
    if (selectedMonth == null && selectedDay == null) {
      return allNotes;
    }

    return allNotes.where((note) {
      bool matchesMonth = selectedMonth == null || DateFormat.MMMM().format(note.noteDateTime) == selectedMonth;
      bool matchesDay = selectedDay == null || note.noteDateTime.day == selectedDay;
      return matchesMonth && matchesDay;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotes,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButton(
                    hint: const Text(
                      "Select Caregiver Name",
                      style: TextStyle(
                        color: Colors.pink,
                      ),
                    ),
                    value: selectedCaregiver,
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
                    items: caregiverList
                        .map<DropdownMenuItem<CaregiverModel>>((parent) {
                      return DropdownMenuItem<CaregiverModel>(
                        value: parent,
                        child: Text(
                          parent.caregiverName,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCaregiver = value;
                        fetchNotesBycaregiverId(selectedCaregiver?.id);
                      });
                    },
                  ),
                  if (selectedCaregiver != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          "Phone number: ${selectedCaregiver!.caregiverPhoneNumber}",
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
                          decoration:
                              InputDecoration(labelText: 'Enter quick note'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          sendNoteToAllCaregivers();
                          noteDetailsController.clear();
                        },
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: "Today's Notes"),
                Tab(text: 'All Notes'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotesList(todayNotes),
                  _buildNotesList(allNotes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(List<NoteModel> notes) {
    Map<String, List<NoteModel>> groupedNotes = {};
    for (var note in notes) {
      String dateKey = DateFormat.yMMMMd().format(note.noteDateTime);
      if (!groupedNotes.containsKey(dateKey)) {
        groupedNotes[dateKey] = [];
      }
      groupedNotes[dateKey]!.add(note);
    }

    List<Widget> noteWidgets = [];
    groupedNotes.forEach((date, notes) {
      noteWidgets.add(
        Card(
          color: Colors.lightBlue[50],
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        ),
      );
      noteWidgets.addAll(notes.map((note) => Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${note.noteStatus}',
                    style: TextStyle(
                      fontSize: 12,
                      color: note.noteStatus == 'UNREAD'
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )));
    });

    return ListView(
      children: noteWidgets,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    String time =
        DateFormat.jm().format(dateTime);
    String date = DateFormat.yMMMd().format(dateTime);
    return '$time, $date';
  }
}
