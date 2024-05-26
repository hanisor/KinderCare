import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  final String childName;
  final Map<String, dynamic> attendanceByDay;

  AttendancePage({required this.childName, required this.attendanceByDay});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String selectedMonth = 'All';
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    List<String> months = _getAvailableMonths(widget.attendanceByDay);

    // Get the timeslot of the first "Present" day as an example
    String timeslot = _getTimeslot(widget.attendanceByDay);

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance for ${widget.childName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Record for ${widget.childName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Timeslot: $timeslot',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedMonth,
              onChanged: (String? newValue) {
                setState(() {
                  selectedMonth = newValue!;
                });
              },
              items: months.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return buildAttendanceTable(widget.attendanceByDay, constraints.maxHeight);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getAvailableMonths(Map<String, dynamic> attendanceByDay) {
    Set<String> months = {'All'};
    attendanceByDay.keys.forEach((day) {
      DateTime dateTime = dateFormat.parse(day);
      String month = DateFormat('MMMM yyyy').format(dateTime);
      months.add(month);
    });
    return months.toList();
  }

  List<MapEntry<String, dynamic>> _getFilteredAttendance() {
    List<MapEntry<String, dynamic>> entries = widget.attendanceByDay.entries.toList();
    if (selectedMonth != 'All') {
      entries = entries.where((entry) {
        DateTime dateTime = dateFormat.parse(entry.key);
        String month = DateFormat('MMMM yyyy').format(dateTime);
        return month == selectedMonth;
      }).toList();
    }
    // Sort by date in descending order
    entries.sort((a, b) => dateFormat.parse(b.key).compareTo(dateFormat.parse(a.key)));
    return entries;
  }

  String _getTimeslot(Map<String, dynamic> attendanceByDay) {
    for (var attendance in attendanceByDay.values) {
      if (attendance is List && attendance.isNotEmpty) {
        var childAttendance = attendance[0];
        return childAttendance['group_timeslot'];
      }
    }
    return 'N/A'; // Default value if no timeslot is found
  }

  Widget buildAttendanceTable(Map<String, dynamic> attendanceByDay, double maxHeight) {
    var filteredAttendance = _getFilteredAttendance();

    return Card(
      color: Color.fromARGB(255, 240, 248, 255),
      elevation: 5,
      margin: const EdgeInsets.all(5.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 50.0,
          columns: const [
            DataColumn(label: Text('No.', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 1, 1)))), // New column for numbering
            DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)))),
            DataColumn(label: Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)))),
          ],
          rows: filteredAttendance.asMap().entries.map((entry) {
            int index = entry.key + 1; // Start numbering from 1
            var day = entry.value.key;
            var attendance = entry.value.value;

            String attendanceStatus = '';

            if (attendance is String) {
              attendanceStatus = attendance;
            } else if (attendance is List) {
              // Assuming there's only one attendance record per day
              var childAttendance = attendance[0];
              attendanceStatus = 'Present';
            }

            // Format the date to dd-MM-yyyy
            DateTime dateTime = dateFormat.parse(day);
            String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);

            return DataRow(cells: [
              DataCell(Text(index.toString())), // Display index
              DataCell(Text(formattedDate)),
              DataCell(Text(
                attendanceStatus,
                style: TextStyle(
                  color: attendanceStatus == 'Absent' ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
