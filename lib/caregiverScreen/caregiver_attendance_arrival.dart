import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importing DateFormat
import 'package:kindercare/model/attendance_model.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/request_controller.dart';
import 'package:provider/provider.dart';

class CaregiverAttendanceArrival extends StatefulWidget {
  final int? caregiverId;
  CaregiverAttendanceArrival({Key? key, this.caregiverId});

  @override
  State<CaregiverAttendanceArrival> createState() => _CaregiverAttendanceArrivalState();
}

class _CaregiverAttendanceArrivalState extends State<CaregiverAttendanceArrival> {
  List<ChildModel> childrenList = [];
  ChildModel? selectedChild;
  Set<int> recordedAttendanceChildren = {}; // Track children with recorded attendance

  @override
  void initState() {
    super.initState();
    if (widget.caregiverId != null) {
      getChildrenData();
    }
  }

  Future<void> getChildrenData() async {
    try {
      RequestController req = RequestController(
          path: 'child-group/caregiverId/${widget.caregiverId}');
      await req.get();
      var response = req.result();
      print("asdrftghyjkl: $response");

      if (response != null && response.containsKey('child_group')) {
        setState(() {
          var childrenData = response['child_group'];
          if (childrenData is List) {
            childrenList =
                List<ChildModel>.from(childrenData.map((x) => ChildModel(
                      childId: int.tryParse(x['id']?.toString() ?? '0'),
                      childName: x['name'] as String? ?? '',
                      childDOB: x['date_of_birth'] as String? ?? '',
                      childGender: x['gender'] as String? ?? '',
                      childMykidNumber: x['my_kid_number'] as String? ?? '',
                      childAllergies: x['allergy'] as String? ?? '',
                      childStatus: x['status'] as String? ?? '',
                      parentId:
                          int.tryParse(x['guardian_id']?.toString() ?? '0'),
                      performances: [],
                    )));

            if (childrenList.isNotEmpty) {
              selectedChild = childrenList[0];
            }
          }
        });
      }
    } catch (e) {
      print("Error during network request: $e");
    }
  }

  Future<void> fetchGroupId(int caregiverId) async {
    try {
      RequestController req = RequestController(path: 'get-group');

      req.setBody({'caregiver_id': caregiverId});

      await req.post();
      var response = req.result();

      if (response != null && response.containsKey('group_id')) {
        int groupId = response['group_id'];
        fetchChildGroupId(selectedChild!.childId, groupId);
        print('group is : $groupId');
      }
    } catch (e) {
      print("Error fetching group ID: $e");
    }
  }

  Future<void> fetchChildGroupId(int? childId, int groupId) async {
    try {
      print(
          "Fetching child group ID for child $childId and group $groupId"); // Debugging line
      RequestController req = RequestController(path: 'get-child-group-id');

      req.setBody({'child_id': childId, 'group_id': groupId});

      print(
          "Sending request to fetch child group ID for child $childId and group $groupId"); // Debugging line
      await req.post();

      var response = req.result();

      print("Raw response: $response"); // Debugging line

      if (response != null) {
        if (response.containsKey('message')) {
          print("Error fetching child group ID: ${response['message']}");
        } else if (response.containsKey('child_group_id')) {
          int childGroupId = response['child_group_id'];
          print("Child group ID found: $childGroupId"); // Debugging line
          recordAttendance(childGroupId);
        } else {
          print("Child group not found in response");
        }
      } else {
        print("No response received");
      }
    } catch (e) {
      print("Error fetching child group ID: $e");
    }
  }

  Future<void> recordAttendance(int childGroupId) async {
    try {
      print("Recording attendance for child group ID: $childGroupId");
      DateTime now = DateTime.now();
      // Formatting the current date time to match the required format
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      RequestController req = RequestController(path: 'add-attendance-arrival');

      print('date before: $formattedDate');
      print('child group ID: $childGroupId');
      req.setBody({
        'date_time_arrive': formattedDate,
        'child_group_id': childGroupId,
      });

      var response = await req.post();
      var responseBody = jsonDecode(response.body);

      print("Attendance record response: $responseBody");

      if (response.statusCode == 200) {
        if (responseBody.containsKey('message')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'])),
          );
        }
      } else if (response.statusCode == 422) {
        // Display an alert dialog informing the user that attendance is already recorded
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Attendance Error'),
            content: Text('Attendance already recorded for this child group today. Do you want to clear this record?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    recordedAttendanceChildren.add(childGroupId);
                    childrenList.removeWhere((child) => child.childId == childGroupId);
                  });
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Yes'),
              ),
            ],
          ),
        );
      } else {
        // For other status codes, display a generic error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording attendance: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Error recording attendance: $e");
      // For exceptions, display a generic error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording attendance')),
      );
    }
  }

  void toggleChildSelection(ChildModel child, AttendanceModel attendanceModel) {
    if (attendanceModel.selectedChildren.contains(child)) {
      attendanceModel.removeChild(child);
    } else {
      attendanceModel.addChild(child);
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
          final dateTime = attendanceModel.selectedDateTime;

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
                  itemCount: attendanceModel.selectedChildren.length,
                  itemBuilder: (context, index) {
                    final child = attendanceModel.selectedChildren[index];

                    // Check if the child exists in the fetched children list and is not already recorded
                    if (childrenList.any((fetchedChild) =>
                        fetchedChild.childId == child.childId) &&
                        !recordedAttendanceChildren.contains(child.childId)) {
                      return Card(
                        child: ListTile(
                          onTap: () {
                            if (widget.caregiverId != null) {
                              fetchGroupId(widget.caregiverId!);
                            }
                          },
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
                      // If the child is not found in the fetched list or attendance is recorded, return an empty container
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
