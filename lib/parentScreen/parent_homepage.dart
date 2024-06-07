import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/note_model.dart';
import 'package:kindercare/parentScreen/parent_attendanceRecord.dart';
import 'package:kindercare/parentScreen/parent_attendance_arrival.dart';
import 'package:kindercare/parentScreen/parent_attendance_departure.dart';
import 'package:kindercare/parentScreen/parent_behaviour.dart';
import 'package:kindercare/parentScreen/parent_note.dart';
import 'package:kindercare/parentScreen/parent_performance.dart';
import 'package:kindercare/parentScreen/parent_pickuprepoprt.dart';
import 'package:kindercare/parentScreen/parent_profile.dart';
import 'package:kindercare/parentScreen/parent_sick.dart';
import 'package:kindercare/role.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../request_controller.dart';

class ParentHomepage extends StatefulWidget {
  ParentHomepage({Key? key});

  @override
  _ParentHomepageState createState() => _ParentHomepageState();
}

class _ParentHomepageState extends State<ParentHomepage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String parentUsername = '';
  int? parentId;
  List<NoteModel> noteList = []; // List to hold checklist items

  Future<void> fetchParentDetails() async {
    try {

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String? email = sharedPreferences.getString('email');
    
      print('parent email : $email');
      final data = await getParentDetails(email);
      print('Response Data: $data');
      setState(() {
        parentUsername = data['username'];
        parentId = data['id'];
        print('ParentUsername after setState: $parentUsername');
        print('ParentUsername after setState: $parentId');
      });
    } catch (error) {
      print('Error fetching parent details: $error'); // Print error to debug
    }
  }

  Future<Map<String, dynamic>> getParentDetails(String? email) async {
    print('email : $email');
    RequestController req =
        RequestController(path: 'guardian-byEmail?email=$email');
    await req.get();
    var response = req.result();
    print("${req.status()}");
    if (req.status() == 200) {
      return response;
    } else {
      throw Exception('Failed to load parent details');
    }
  }

  Future<void> fetchNotesByCaregiver() async {
    RequestController req = RequestController(
        path: 'note/sendby-caregiver'); // Pass email as parameter

    await req.get();
    var response = req.result();
    if (response != null && response is List) {
      setState(() {
        noteList = List<NoteModel>.from(response.map((x) {
          // Ensure noteId is parsed as an integer
          x['id'] = int.tryParse(x['id'].toString());
          print("noteId: ${x['id']}"); // Debug noteId
          print("noteStatus: ${x['status']}"); // Debug noteStatus
          return NoteModel.fromJson(x);
        }).where((item) =>
            item.noteStatus == 'UNREAD' &&
            item.parentId == parentId &&
            item.senderType ==
                'caregiver')); // Filter items with status 'Pending'

        // Sort notes by date time (optional)
        noteList.sort((a, b) => a.noteDateTime.compareTo(b.noteDateTime));

        print("Updated noteList: $noteList"); // Print updated noteList

        print("Updated noteList: $noteList"); // Print updated noteList
      });
    }
  }

  Future<void> updateNoteStatus(int? noteId, int index) async {
    // Prepare the request body with the status "Taken"
    Map<String, dynamic> requestBody = {};
    NoteModel item = noteList[index];

    if (item.noteStatus == "UNREAD") {
      requestBody["status"] = "READ";
      item.noteStatus = "READ";
    }

    // Create an instance of RequestController
    RequestController req =
        RequestController(path: 'note/update-status/$noteId');

    req.setBody(requestBody);
    await req.put();

    print(req.result());
    if (req.status() == 200) {
      Fluttertoast.showToast(
        msg: 'Update successfully',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Update failed!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchParentDetails(); // Call fetchParentDetails when the widget is initialized
    print('InitState: ParentUsername: $parentUsername');
  }

  Future<void> _refreshData() async {
    // Implement the logic to refresh data here
    await fetchParentDetails(); // Call the method to fetch parent details again
    await fetchNotesByCaregiver();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.pinkAccent,
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Hi $parentUsername :)",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                _buildSection(
                  icon: Icons.schedule,
                  title: 'Working Hours',
                  content: 'Mon - Fri: 8:00 am - 6:00 pm\nSat - Sun: Closed',
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title for the section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'Notes from Caregiver',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Container for the notes section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 300, // Adjust height as needed
                        child: noteList.isEmpty
                            ? const Center(
                                child: Text(
                                  'No Notes',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: noteList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  NoteModel item = noteList[index];
                                  return Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: ListTile(
                                      title: RichText(
                                        text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style,
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:
                                                  'From: Caregiver ${item.caregiverModel?.caregiverUsername}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.noteDetails),
                                          Text(_formatDateTime(
                                              item.noteDateTime)),
                                        ],
                                      ),
                                      trailing: Checkbox(
                                        value: item.noteStatus == 'READ',
                                        onChanged: (bool? value) {
                                          setState(() {
                                            item.noteStatus =
                                                value! ? 'READ' : 'UNREAD';
                                          });
                                          // Call updateSicknessStatus when the checkbox is toggled
                                          updateNoteStatus(item.noteId,
                                              index); // Pass index here
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ParentAttendanceArrival(parentId: parentId)),
                        );
                      },
                      child: Container(
                        width: 147,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.schedule,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Attendance',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Arrival',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ParentAttendanceDeparture(
                                    parentId: parentId,
                                  )),
                        );
                      },
                      child: Container(
                        width: 147,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.schedule,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Attendance',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Departure',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ParentNote(parentId: parentId)),
                        );
                      },
                      child: Container(
                        width: 85,
                        height: 104,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.edit_note,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Notes',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ParentSickness(parentId: parentId)),
                        );
                      },
                      child: Container(
                        width: 85,
                        height: 104,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.sick_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sick',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ParentPickupReport(parentId: parentId)),
                        );
                      },
                      child: Container(
                        width: 111,
                        height: 104,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                            Text(
                              'Authorize',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Pick-up',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ParentBehaviour(parentId: parentId)));
                      },
                      child: Container(
                        width: 130,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.sentiment_very_satisfied,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Behaviour',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ParentPerformance(parentId: parentId)));
                      },
                      child: Container(
                        width: 170,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Performance',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
              ),
              child: Text(
                "Hi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ParentHomepage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ParentProfile()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('Attendance Report'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ParentAttendanceRecord (parentId: parentId)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();

                // Print shared preferences before removal
                print('SharedPreferences before logout:');
                print('email: ${sharedPreferences.getString('email')}');
                print('token: ${sharedPreferences.getString('token')}');
                print('role: ${sharedPreferences.getString('role')}');

                // Remove the shared preferences
                await sharedPreferences.remove('email');
                await sharedPreferences.remove('token');
                await sharedPreferences.remove('role');

                // Print shared preferences after removal
                print('SharedPreferences after logout:');
                print('email: ${sharedPreferences.getString('email')}');
                print('token: ${sharedPreferences.getString('token')}');
                print('role: ${sharedPreferences.getString('role')}');

                // Navigate to Role screen
                Get.offAll(Role());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required IconData icon,
      required String title,
      required String content,
      Color? color}) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(content),
        onTap: () {
          // Handle section tap
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Format the DateTime object in 12-hour system with AM/PM indicator
    return DateFormat('MMMM dd, yyyy hh:mm a').format(dateTime);
  }
}
