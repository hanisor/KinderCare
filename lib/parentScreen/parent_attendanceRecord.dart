import 'package:flutter/material.dart';
import 'package:kindercare/parentScreen/attendance-page.dart';
import 'package:kindercare/request_controller.dart';
import '../model/child_model.dart';

class ParentAttendanceRecord extends StatefulWidget {
  final int? parentId;

  ParentAttendanceRecord({Key? key, this.parentId});

  @override
  State<ParentAttendanceRecord> createState() => _ParentAttendanceRecordState();
}

class _ParentAttendanceRecordState extends State<ParentAttendanceRecord> {
  List<ChildModel> childrenList = [];
  Map<String, dynamic>? attendanceByDay;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    getChildrenData();
  }

  Future<void> getChildrenData() async {
    try {
      RequestController req = RequestController(path: 'child/by-guardianId/${widget.parentId}');
      await req.get();
      var response = req.result();
      if (response != null && response.containsKey('children')) {
        setState(() {
          var childrenData = response['children'];
          if (childrenData is List) {
            childrenList = List<ChildModel>.from(childrenData.map((x) =>
                ChildModel(
                  childId: int.tryParse(x['id'].toString()),
                  childName: x['name'] as String,
                  childDOB: x['date_of_birth'] as String,
                  childGender: x['gender'] as String,
                  childMykidNumber: x['my_kid_number'] as String,
                  childAllergies: x['allergy'] as String,
                  childStatus: x['status'] as String,
                  parentId: widget.parentId,
                  performances: [],
                )));
          } else {
            showErrorDialog("Invalid children data format");
          }
        });
      } else {
        showErrorDialog("Failed to fetch children data");
      }
    } catch (e) {
      showErrorDialog('Error fetching children data: $e');
    }
  }

  Future<void> getchildgroupbychildid(int childId, String childName) async {
    try {
      RequestController req = RequestController(path: 'child-group/childId/$childId');
      await req.get();
      var response = req.result();

      if (req.status() == 200 && response != null && response.containsKey('child_group_id')) {
        int childGroupId = response['child_group_id'];
        fetchChildAttendance(childGroupId, childName);
      } else {
        showErrorDialog('Child group not found');
      }
    } catch (e) {
      showErrorDialog('Error fetching child group: $e');
    }
  }

  Future<void> fetchChildAttendance(int childGroupId, String childName) async {
    try {
      RequestController req = RequestController(path: 'attendance/child');
      req.setBody({'child_group_id': childGroupId});
      await req.post();
      var response = req.result();

      if (response != null && response.containsKey('attendance_by_day')) {
        setState(() {
          attendanceByDay = response['attendance_by_day'];
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendancePage(
              childName: childName,
              attendanceByDay: attendanceByDay!,
            ),
          ),
        );
      } else {
        showErrorDialog('Failed to fetch attendance data');
      }
    } catch (e) {
      showErrorDialog('Error fetching attendance: $e');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildKids() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Children List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
          ),
          ...childrenList.map((child) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade800,
                    child: const Icon(Icons.child_care, color: Colors.white),
                  ),
                  title: Text(
                    child.childName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Date Of Birth: ${child.childDOB}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gender: ${child.childGender}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Allergy: ${child.childAllergies}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    getchildgroupbychildid(child.childId!, child.childName);
                  },
                ),
              ),
            );
          }).toList(),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Children Attendance'),
      ),
      body: errorMessage.isNotEmpty
          ? Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Children List',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: childrenList.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.pinkAccent,
                          ),
                        )
                      : ListView.builder(
                          itemCount: childrenList.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey.shade800,
                                  child: const Icon(Icons.child_care,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  childrenList[index].childName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'Date Of Birth: ${childrenList[index].childDOB}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Gender: ${childrenList[index].childGender}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Allergy: ${childrenList[index].childAllergies}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  int childId = childrenList[index].childId!;
                                  getchildgroupbychildid(childId, childrenList[index].childName);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
