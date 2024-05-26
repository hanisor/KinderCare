import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/request_controller.dart';

class CaregiverReport extends StatefulWidget {
  const CaregiverReport({super.key});

  @override
  State<CaregiverReport> createState() => _CaregiverReportState();
}

class _CaregiverReportState extends State<CaregiverReport> {
  String childname = '';
  String childmykidnumber = '';
  String caregiverIcNumber = '';
  String childdob = '';
  String gender = '';
  String alllergy = '';
  String guardianName = '';
  String errorMessage = '';
  List<dynamic> children = []; // Store children data

  Future<void> getgroupidbytimeslot(String? timeslot) async {
    print('timeslot : $timeslot');
    RequestController req =
        RequestController(path: 'child-group/time?time=$timeslot');

    await req.get();
    var response = req.result();
    print("${req.status()}");
    if (req.status() == 200) {
      print('response: $response');
      var groupId = response['group_id'];
      print('groupid: $groupId');
      await getchildbygroupid(groupId);
    } else {
      setState(() {
        errorMessage = 'Failed to load parent details';
      });
    }
  }

  Future<void> getchildbygroupid(int? groupId) async {
    print('groupId : $groupId');
    RequestController req = RequestController(path: 'child-group/$groupId');

    await req.get();
    var response = req.result();
    print("${req.status()}");
    if (req.status() == 200) {
      setState(() {
        children = response['child_group'];
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load child group details';
      });
    }
  }

  // Helper function to calculate age based on year only
  int calculateAge(String dob) {
    try {
      DateTime birthDate = DateFormat('MM/dd/yyyy').parse(dob); // Adjust format as needed
      DateTime today = DateTime.now();
      return today.year - birthDate.year;
    } catch (e) {
      print('Error parsing date: $e');
      return 0; // Default age if parsing fails
    }
  }

  final List<String> _timeSlots = [
    "08:00 AM - 03:00 PM",
    "02:00 PM - 06:00 PM",
    "08:00 AM - 06:00 PM"
  ];

  String? _selectedTimeSlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Report'),
        backgroundColor: Colors.pink[50],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color.fromARGB(255, 0, 0, 0)),
            onPressed: () {
              setState(() {
                children = [];
                _selectedTimeSlot = null;
                errorMessage = '';
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Select Time Slot:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 1.0),
                  color: Colors.pink[50],
                ),
                child: DropdownButton<String>(
                  value: _selectedTimeSlot,
                  hint: const Text('Choose a time slot'),
                  icon: Icon(Icons.arrow_drop_down, color: const Color.fromARGB(255, 0, 0, 0)),
                  isExpanded: true,
                  underline: SizedBox(),
                  onChanged: (String? newValue) async {
                    setState(() {
                      _selectedTimeSlot = newValue;
                    });
                    if (newValue != null) {
                      await getgroupidbytimeslot(newValue);
                    }
                  },
                  items: _timeSlots.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: children.isNotEmpty
                  ? Card(
                      color: Color.fromARGB(255, 240, 248, 255),
                      elevation: 5,
                      margin: const EdgeInsets.all(5.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 16.0,
                          columns: const [
                            DataColumn(label: Text('No.', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 1, 1)))), // New column for numbering
                            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)))),
                            DataColumn(label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)))), // New column for age
                            DataColumn(label: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)))),
                            DataColumn(label: Text('Guardian Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)))),
                          ],
                          rows: children.asMap().entries.map((entry) {
                            int index = entry.key + 1; // Start numbering from 1
                            var child = entry.value;
                            return DataRow(cells: [
                              DataCell(Text(index.toString())), // Display index
                              DataCell(Text(child['name'])),
                              DataCell(Text(calculateAge(child['date_of_birth']).toString())), // Display age
                              DataCell(Text(child['gender'])),
                              DataCell(Text(child['guardian_name'])),
                            ]);
                          }).toList(),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        errorMessage.isNotEmpty ? errorMessage : 'No data found',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
