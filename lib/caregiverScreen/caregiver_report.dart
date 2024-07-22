import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/model/parent_model.dart';
import 'package:kindercare/model/performance_model.dart';
import 'package:kindercare/request_controller.dart';

class CaregiverReport extends StatefulWidget {
  final int? caregiverId;
  CaregiverReport({Key? key, this.caregiverId});

  @override
  State<CaregiverReport> createState() => _CaregiverReportState();
}

class _CaregiverReportState extends State<CaregiverReport> {
  String errorMessage = '';
  List<ChildModel> childrenList = [];

  @override
  void initState() {
    super.initState();
    fetchGroupId(widget.caregiverId!).then((groupId) {
      if (groupId != null) {
        getChildrenData(groupId);
      } else {
        print("Failed to get group ID for caregiver");
      }
    });
  }
  Future<int?> fetchGroupId(int caregiverId) async {
    try {
      RequestController req = RequestController(path: 'get-group');
      req.setBody({"caregiver_id": caregiverId});
      await req.post();
      var response = req.result();
      if (response != null && response.containsKey('group_id')) {
        return response['group_id'] as int;
      } else {
        print("Failed to fetch group ID");
        return null;
      }
    } catch (e) {
      print("Error during network request: $e");
      return null;
    }
  }

  Future<void> getChildrenData(int groupId) async {
    print("Fetching children data for groupid: $groupId"); // Debugging line

    try {
      RequestController req =
          RequestController(path: 'child-group/caregiverId/$groupId');
      await req.get();
      var response = req.result();
      print("Request result: $response"); // Print the response to see its type

      if (response != null && response.containsKey('group')) {
        setState(() {
          var childrenData = response['group'];
          print("Children Data: $childrenData"); // Debugging line

          if (childrenData is List) {
            childrenList = List<ChildModel>.from(childrenData.map((x) => ChildModel(
              childId: int.tryParse(x['id']?.toString() ?? ''),
              childName: x['name'] as String? ?? '',
              childDOB: x['date_of_birth'] as String? ?? '',
              childGender: x['gender'] as String? ?? '',
              childMykidNumber: x['my_kid_number'] as String? ?? '',
              childAllergies: x['allergy'] as String? ?? '',
              childStatus: x['status'] as String? ?? '',
              parentId: int.tryParse(x['guardian_id']?.toString() ?? ''),
              performances: x['performances'] != null && x['performances'] is List
                ? List<PerformanceModel>.from((x['performances'] as List).map((e) => PerformanceModel.fromJson(e as Map<String, dynamic>)))
                : [],
              guardian: x['guardians'] != null
                ? ParentModel.fromJson(x['guardians'])
                : ParentModel(
                  parentName: x['guardian_name'] as String? ?? '', 
                  parentPhoneNumber: '',
                  parentICNumber: '', 
                  parentEmail: '', 
                  parentPassword: '', 
                  parentUsername: '', 
                  parentRole: '', 
                  parentStatus: ''), // Set guardian name
            )));
          }
        });
      } else {
        print("Failed to fetch children data or key 'child_group' not found"); // Debugging line
        setState(() {
          errorMessage = "Failed to fetch children data or key 'child_group' not found";
        });
      }
      print("childrenList: $childrenList");
    } catch (e) {
      print("Error during network request: $e");
      setState(() {
        errorMessage = "Error during network request: $e";
      });
    }
  }

 // Function to calculate age from date of birth
  int _calculateAge(String dateOfBirth) {
    try {
      DateTime dob = DateFormat("yyyy-MM-dd").parse(dateOfBirth);
      DateTime today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      print("Error parsing date of birth: $e");
      return -1; // Return a negative value to indicate an error
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Report'),
        backgroundColor: Colors.pink[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [            
            const SizedBox(height: 16),
            Expanded(
              child: childrenList.isNotEmpty
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
                          rows: childrenList.asMap().entries.map((entry) {
                            int index = entry.key + 1; // Start numbering from 1
                            var child = entry.value;
                            return DataRow(cells: [
                              DataCell(Text(index.toString())), // Display index
                              DataCell(Text(child.childName)),
                              DataCell(Text(_calculateAge(child.childDOB).toString())), // Display age
                              DataCell(Text(child.childGender)),
                              DataCell(Text(child.guardian?.parentName ?? '')), // Display guardian name
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
