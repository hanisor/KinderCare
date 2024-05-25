import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindercare/model/attendance_model.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/request_controller.dart';
import 'package:provider/provider.dart';

class CaregiverAttendanceDeparture extends StatefulWidget {
  final int? caregiverId;

  CaregiverAttendanceDeparture({Key? key, this.caregiverId}) : super(key: key);

  @override
  State<CaregiverAttendanceDeparture> createState() =>
      _CaregiverAttendanceDepartureState();
}

class _CaregiverAttendanceDepartureState
    extends State<CaregiverAttendanceDeparture> {
  late DateTime _selectedDateTime;
  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
    _fetchDataFuture = fetchGroupId(widget.caregiverId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Attendance"),
      ),
      body: FutureBuilder<void>(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching data: ${snapshot.error}'));
          } else {
            return Consumer<AttendanceModel>(
              builder: (context, attendanceModel, child) {
                final selectedChildren = attendanceModel.selectedChildren;

                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Confirm the attendance for the following children:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: selectedChildren.isEmpty
                          ? Center(child: Text('No children selected.'))
                          : ListView.builder(
                              itemCount: selectedChildren.length,
                              itemBuilder: (context, index) {
                                final child = selectedChildren[index];

                                return Card(
                                  child: ListTile(
                                    onTap: () {
                                      toggleChildSelection(
                                          context, child, attendanceModel);
                                    },
                                    leading: CircleAvatar(
                                      child: Text(child.childName[0]),
                                    ),
                                    title: Text(child.childName),
                                    subtitle: Text(
                                      'DOB: ${child.childDOB}\nGender: ${child.childGender}\nAllergies: ${child.childAllergies}\nDate: ${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}  Time: ${_selectedDateTime.hour}:${_selectedDateTime.minute}',
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        attendanceModel.selectedChildren
                                                .contains(child)
                                            ? Icons.check_circle
                                            : Icons.check_circle_outline,
                                      ),
                                      onPressed: () {
                                        toggleChildSelection(
                                            context, child, attendanceModel);
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
            );
          }
        },
      ),
    );
  }

  Future<void> fetchGroupId(int? caregiverId) async {
    try {
      RequestController req = RequestController(path: 'get-group');

      req.setBody({'caregiver_id': caregiverId});

      var response = await req.post();

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        if (responseBody != null && responseBody.containsKey('group_id')) {
          int groupId = responseBody['group_id'];

          await fetchChildrenData(caregiverId, groupId);
        } else {
          throw Exception('Failed to fetch group ID');
        }
      } else {
        throw Exception('Failed to fetch group ID: ${response.statusCode}');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> fetchChildrenData(int? caregiverId, int groupId) async {
    if (caregiverId == null) {
      throw Exception('caregiverId is null');
    }
    try {
      RequestController req = RequestController(path: 'attendance/all');

      req.setBody({
        'caregiver_id': caregiverId,
        'group_id': groupId,
      });

      var response = await req.post();
      var responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody != null && responseBody['attendances'] != null) {
          List<ChildModel> children = (responseBody['attendances'] as List)
              .map((attendance) {
                if (attendance['child_name'] != null) {
                  return ChildModel.fromAttendanceJson(attendance);
                } else {
                  return null;
                }
              })
              .where((child) => child != null)
              .cast<ChildModel>()
              .toList();

          Provider.of<AttendanceModel>(context, listen: false)
            ..setSelectedChildren(children)
            ..setSelectedDateTime(_selectedDateTime);
        }
      } else {
        throw Exception('Failed to fetch children data');
      }
    } catch (e) {
      throw Exception('Failed to fetch children data: $e');
    }
  }

  void toggleChildSelection(
      BuildContext context, ChildModel child, AttendanceModel attendanceModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Selection'),
          content: Text(
            'Are you sure you want to select ${child.childName}?\n\nDate: ${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year}\nTime: ${_selectedDateTime.hour}:${_selectedDateTime.minute}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                if (!attendanceModel.selectedChildren.contains(child)) {
                  attendanceModel.addChild(child);
                  Fluttertoast.showToast(
                    msg:
                        "Child data is sending to the parent for double-check.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "This child is already selected.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
