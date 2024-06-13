import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/attendance_model.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/request_controller.dart';
import 'package:provider/provider.dart';

class CaregiverAttendanceArrival extends StatefulWidget {
  final int? caregiverId;

  CaregiverAttendanceArrival({Key? key, this.caregiverId});

  @override
  State<CaregiverAttendanceArrival> createState() =>
      _CaregiverAttendanceArrivalState();
}

class _CaregiverAttendanceArrivalState
    extends State<CaregiverAttendanceArrival> {
  List<ChildModel> childrenList = [];
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

      if (response != null && response.containsKey('child_group')) {
        setState(() {
          var childrenData = response['child_group'];
          if (childrenData is List) {
            childrenList = List<ChildModel>.from(childrenData.map((x) {
              print('Processing child data: $x'); // Debug print
              return ChildModel(
                childId: int.tryParse(x['id']?.toString() ?? '0'),
                childName: x['name'] as String? ?? '',
                childDOB: x['date_of_birth'] as String? ?? '',
                childGender: x['gender'] as String? ?? '',
                childMykidNumber: x['my_kid_number'] as String? ?? '',
                childAllergies: x['allergy'] as String? ?? '',
                childStatus: x['status'] as String? ?? '',
                parentId: int.tryParse(x['guardian_id']?.toString() ?? '0'),
                performances: [],
              );
            }));
          }
        });
      }
    } catch (e) {
      print("Error during network request: $e");
    }
  }

  Future<void> fetchGroupId(int caregiverId, int? childId) async {
    try {
      RequestController req = RequestController(path: 'get-group');
      req.setBody({'caregiver_id': caregiverId});
      await req.post();
      var response = req.result();

      if (response != null && response.containsKey('group_id')) {
        int groupId = response['group_id'];
        fetchChildGroupId(childId, groupId); // Pass the correct child ID
      }
    } catch (e) {
      print("Error fetching group ID: $e");
    }
  }

  Future<void> fetchChildGroupId(int? childId, int groupId) async {
    try {
      print('child_id: $childId, group_id: $groupId');
      RequestController req = RequestController(path: 'get-child-group-id');
      req.setBody({'child_id': childId, 'group_id': groupId});
      await req.post();

      var response = req.result();

      if (response != null) {
        if (response.containsKey('message')) {
          print("Error fetching child group ID: ${response['message']}");
        } else if (response.containsKey('child_group_id')) {
          int childGroupId = response['child_group_id'];
          recordAttendance(childGroupId);
        }
      }
    } catch (e) {
      print("Error fetching child group ID: $e");
    }
  }

  Future<void> recordAttendance(int childGroupId) async {
    try {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      RequestController req = RequestController(path: 'add-attendance-arrival');

      req.setBody({
        'date_time_arrive': formattedDate,
        'child_group_id': childGroupId,
      });

      var response = await req.post();
      var responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody.containsKey('message')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'])),
          );
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
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    recordedAttendanceChildren.add(childGroupId);
                    childrenList.removeWhere((child) => child.childId == childGroupId);
                  });
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error recording attendance: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Error recording attendance: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error recording attendance')),
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

          // Filter the childrenList to include only those which are not recorded and are unique
          final filteredChildrenList = attendanceModel.selectedChildren
              .where((child) =>
                  childrenList.any((fetchedChild) => fetchedChild.childId == child.childId) &&
                  !recordedAttendanceChildren.contains(child.childId))
              .toSet()
              .toList();

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
                  itemCount: filteredChildrenList.length,
                  itemBuilder: (context, index) {
                    final child = filteredChildrenList[index];
                    return Card(
                      child: ListTile(
                        onTap: () {
                          if (widget.caregiverId != null) {
                            fetchGroupId(widget.caregiverId!, child.childId); // Pass the correct child ID
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
