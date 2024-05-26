import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/caregiverScreen/caregiver_attendance_arrival.dart';
import 'package:kindercare/caregiverScreen/caregiver_attendance_departure.dart';
import 'package:kindercare/caregiverScreen/caregiver_behaviorReport.dart';
import 'package:kindercare/caregiverScreen/caregiver_note.dart';
import 'package:kindercare/caregiverScreen/caregiver_performanceReport.dart';
import 'package:kindercare/caregiverScreen/caregiver_pickup.dart';
import 'package:kindercare/caregiverScreen/caregiver_profile.dart';
import 'package:kindercare/caregiverScreen/caregiver_report.dart';
import 'package:kindercare/caregiverScreen/caregiver_sick.dart';
import 'package:kindercare/model/note_model.dart';
import 'package:kindercare/request_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../role.dart';
import 'caregiver_parentregister.dart';

class CaregiverHomepage extends StatefulWidget {
  @override
  _CaregiverHomepageState createState() => _CaregiverHomepageState();
}

class _CaregiverHomepageState extends State<CaregiverHomepage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String caregiverUsername = '';
  int? caregiverId;
  List<NoteModel> noteList = []; // List to hold checklist items

  Future<void> fetchCaregiverDetails() async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? email = sharedPreferences.getString('email');
    
      print('parent email : $email');
      final data = await getCaregiverDetails(email);
      print('Response Data: $data');
      setState(() {
        caregiverUsername = data['username'];
        caregiverId = data['id'];

        print('caregiverUsername after setState: $caregiverUsername');
      });
    } catch (error) {
      print('Error fetching caregiver details: $error'); // Print error to debug
    }
  }

  Future<Map<String, dynamic>> getCaregiverDetails(String? email) async {
    print('email : $email');
    RequestController req =
        RequestController(path: 'caregiver-byEmail?email=$email');

    await req.get();
    var response = req.result();
    print("response = ${req.result()}");
    print("status = ${req.status()}");
    if (req.status() == 200) {
      return response;
    } else {
      throw Exception('Failed to load caregiver details');
    }
  }

  Future<void> fetchNotesByCaregiver() async {
    RequestController req = RequestController(
        path: 'note/sendby-parent'); // Pass email as parameter

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
            item.caregiverId== caregiverId &&
            item.senderType == 'parent')); // Filter items with status 'Pending'

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
    fetchCaregiverDetails();
    print('InitState: caregiverUsername: $caregiverUsername');
  }

  Future<void> _refresh() async {
    // Call fetchCaregiverDetails and fetchNotesByParentId again
    await fetchCaregiverDetails();
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
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Hi $caregiverUsername :)",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildSection(
                icon: Icons.app_registration,
                title: 'Registration',
                content: 'Parent and children Registration',
              ),
              const SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title for the section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      'Notes from Parents',
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
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                'Parent Name: ${item.parentModel?.parentName}',
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
                                        Text(
                                            _formatDateTime(item.noteDateTime)),
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
              const SizedBox(height: 15),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CaregiverAttendanceArrival(caregiverId: caregiverId,)),
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
                            builder: (context) => CaregiverAttendanceDeparture(caregiverId: caregiverId)),
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
                                CaregiverNote(caregiverId: caregiverId)),
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
                            builder: (context) => CaregiverSickness(caregiverId: caregiverId)),
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
                            builder: (context) => const CaregiverPickup()),
                      );
                    },
                    child: Container(
                      width: 110,
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
                            builder: (context) => CaregiverBehaviourReport(caregiverId: caregiverId)),
                      );
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
                      child:  Column(
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
                            builder: (context) => CaregiverPerformanceReport(caregiverId: caregiverId)),
                      );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CaregiverHomepage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CaregiverProfile()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('Report'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CaregiverReport()),
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
          if (title == 'Registration') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterPage(),
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Format the DateTime object in 12-hour system with AM/PM indicator
    return DateFormat('MMMM dd, yyyy hh:mm a').format(dateTime);
  }
}
