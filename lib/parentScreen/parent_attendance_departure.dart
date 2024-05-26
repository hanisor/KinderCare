import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/attendance_model.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/request_controller.dart';
import 'package:provider/provider.dart';

class ParentAttendanceDeparture extends StatefulWidget {
  final int? parentId;

  ParentAttendanceDeparture({Key? key, this.parentId}) : super(key: key);

  @override
  State<ParentAttendanceDeparture> createState() => _ParentAttendanceDepartureState();
}

class _ParentAttendanceDepartureState extends State<ParentAttendanceDeparture> {
  Set<int> recordedAttendanceChildren = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> recordAttendance(int childGroupId, AttendanceModel attendanceModel, ChildModel child) async {
    try {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      RequestController req = RequestController(path: 'add-attendance-departure');

      req.setBody({
        'date_time_leave': formattedDate,
        'child_group_id': childGroupId,
      });

      var response = await req.post();
      var responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody.containsKey('message')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'])),
          );
          // Remove the child group ID from the recordedAttendanceChildren set
          recordedAttendanceChildren.remove(childGroupId);
          // Clear the attendance model by removing the child from the selected children list
          attendanceModel.removeChild(child);
        }
      } else if (response.statusCode == 422) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Attendance Error'),
            content: const Text(
                'Attendance already recorded for this child group today. Do you want to clear this record?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    recordedAttendanceChildren.remove(childGroupId);
                  });
                  Navigator.pop(context);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording attendance: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error recording attendance')),
      );
    }
  }

  Future<void> fetchChildGroupId(int? childId, AttendanceModel attendanceModel, ChildModel child) async {
    try {
      RequestController req = RequestController(path: 'attendance/$childId/childgroupid');
      await req.get();
      var response = req.result();

      if (response != null) {
        if (response is Map<String, dynamic>) {
          final responseData = response as Map<String, dynamic>;
          final childGroupId = responseData['child_group_id'];

          await recordAttendance(childGroupId, attendanceModel, child);

          // Use the retrieved child group ID as needed
          print('Child Group ID: $childGroupId');
        } else {
          throw Exception('Failed to fetch child group ID');
        }
      } else {
        throw Exception('Failed to fetch child group ID: ${req.status()}');
      }
    } catch (e) {
      throw e;
    }
  }

  void toggleChildSelection(ChildModel child, AttendanceModel attendanceModel) {
    if (attendanceModel.selectedChildren.contains(child)) {
      attendanceModel.removeChild(child);
    } else {
      attendanceModel.addChild(child);
    }
  }

  void confirmAttendance(ChildModel child, AttendanceModel attendanceModel) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Attendance'),
        content: Text('Do you want to record the attendance for ${child.childName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await fetchChildGroupId(child.childId, attendanceModel, child);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Attendance"),
      ),
      body: Consumer<AttendanceModel>(
        builder: (context, attendanceModel, child) {
          final selectedChildren = attendanceModel.selectedChildren;
          final dateTime = attendanceModel.selectedDateTime;
          print("Selected datetime: $dateTime");

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Confirm the attendance for the following children:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: selectedChildren.length,
                  itemBuilder: (context, index) {
                    final child = selectedChildren[index];

                    if (!recordedAttendanceChildren.contains(child.childId)) {
                      return Card(
                        child: ListTile(
                          onTap: () => confirmAttendance(child, attendanceModel),
                          leading: CircleAvatar(
                            child: Text(child.childName[0]),
                          ),
                          title: Text(child.childName),
                          subtitle: Text(
                              'DOB: ${child.childDOB}\nGender: ${child.childGender}\nAllergies: ${child.childAllergies}\nDate: ${dateTime?.day}/${dateTime?.month}/${dateTime?.year}  Time: ${dateTime?.hour}:${dateTime?.minute}'),
                          trailing: IconButton(
                            icon: Icon(
                                attendanceModel.selectedChildren.contains(child)
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline),
                            onPressed: () {
                              toggleChildSelection(child, attendanceModel);
                            },
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
