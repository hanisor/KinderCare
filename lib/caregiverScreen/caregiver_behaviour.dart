import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/caregiverScreen/caregiver_behaviorReport.dart';
import 'package:kindercare/model/behaviour_model.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/model/performance_model.dart';
import 'package:kindercare/request_controller.dart';

class CaregiverBehaviour extends StatefulWidget {
  final int? caregiverId;
  CaregiverBehaviour({Key? key, this.caregiverId});

  @override
  State<CaregiverBehaviour> createState() => _CaregiverBehaviourState();
}

class _CaregiverBehaviourState extends State<CaregiverBehaviour> {
  TextEditingController behaviourController = TextEditingController();
  String? type;
  String? description;
  DateTime? dateTime;
  List<BehaviourModel> behaviourList = [];
  ChildModel? selectedChild;
  List<ChildModel> childrenList = [];
  List<String> emotionTypes = ['Happy', 'Sad', 'Angry', 'Excited', 'Calm'];

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
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
    print("Fetching children data for groupid: $groupId");

    try {
      RequestController req =
          RequestController(path: 'child-group/caregiverId/$groupId');
      await req.get();
      var response = req.result();
      print("Request result: $response");

      if (response != null && response.containsKey('group')) {
        setState(() {
          var childrenData = response['group'];
          print("Children Dataaaa: $childrenData");

          if (childrenData is List) {
            childrenList =
                List<ChildModel>.from(childrenData.map((x) => ChildModel(
                      childId: int.tryParse(x['id']?.toString() ?? ''),
                      childName: x['name'] as String? ?? '',
                      childDOB: x['date_of_birth'] as String? ?? '',
                      childGender: x['gender'] as String? ?? '',
                      childMykidNumber: x['my_kid_number'] as String? ?? '',
                      childAllergies: x['allergy'] as String? ?? '',
                      childStatus: x['status'] as String? ?? '',
                      parentId:
                          int.tryParse(x['guardian_id']?.toString() ?? ''),
                      performances:
                          x['performances'] != null && x['performances'] is List
                              ? List<PerformanceModel>.from(
                                  (x['performances'] as List).map((e) =>
                                      PerformanceModel.fromJson(
                                          e as Map<String, dynamic>)))
                              : [],
                    )));

            if (childrenList.isNotEmpty) {
              selectedChild = childrenList[0];
              print(
                  'Selected child dataaaa: ${selectedChild!.childId.toString()}');
            }
          } else {
            print("Invalid children data format");
          }
        });
      } else {
        print("Failed to fetch children data or key 'child_group' not found");
      }
      print("childrenList: $childrenList");
    } catch (e) {
      print("Error during network request: $e");
    }
  }

  Future<void> addBehaviour() async {
    try {
      if (type == null ||
          description == null ||
          dateTime == null ||
          selectedChild == null) {
        return;
      }

      String formattedDateTime =
          DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime!);

      RequestController req = RequestController(path: 'add-behaviour');

      req.setBody({
        "type": type,
        "description": description,
        "date_time": formattedDateTime,
        "child_id": selectedChild!.childId.toString(),
      });

      var response = await req.post();

      if (response.statusCode == 200) {
        var result = req.result();

        if (result != null) {
          print('Behavior report saved successfully');
          await showCustomDialog(
            context,
            'Success!',
            'Behavior report added successfully!',
            Icons.check_circle,
            Colors.green,
          );
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CaregiverBehaviourReport(),
              ),
            );
          }
        } else {
          print('Error saving behavior report');
          await showCustomDialog(
            context,
            'Error',
            'Failed to save behavior report.',
            Icons.error,
            Colors.red,
          );
        }
      } else {
        print(
            'Error: HTTP request failed with status code ${response.statusCode}');
        await showCustomDialog(
          context,
          'Error',
          'Failed to save behavior report.',
          Icons.error,
          Colors.red,
        );
      }
    } catch (e) {
      print('Error: $e');
      await showCustomDialog(
        context,
        'Error',
        'An error occurred: $e',
        Icons.error,
        Colors.red,
      );
    }
  }

  Future<void> showCustomDialog(BuildContext context, String title,
      String message, IconData icon, Color iconColor) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Row(
            children: [
              Icon(icon, color: iconColor),
              SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK', style: TextStyle(color: iconColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Behaviour'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButton(
              hint: const Text(
                "Select Child ",
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
              value: selectedChild?.childName,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.pink,
              ),
              elevation: 4,
              style: const TextStyle(
                color: Colors.pink,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              underline: Container(
                height: 2,
                color: Colors.pink,
              ),
              items: childrenList.map<DropdownMenuItem<String>>((child) {
                return DropdownMenuItem<String>(
                  value: child.childName,
                  child: Text(
                    child.childName,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedChild = childrenList
                      .firstWhere((child) => child.childName == value);
                });
              },
            ),
            if (selectedChild != null) ...[
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              hint: const Text(
                "Select Emotion",
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
              value: type,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.pink,
              ),
              elevation: 4,
              style: const TextStyle(
                color: Colors.pink,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                labelText: 'Emotion',
                labelStyle: TextStyle(color: Colors.pink),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
              ),
              items: emotionTypes.map((emotion) {
                return DropdownMenuItem<String>(
                  value: emotion,
                  child: Text(
                    emotion,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  type = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: behaviourController,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.pink),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
              ),
              maxLines: null,
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Date & Time: ${DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime!)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addBehaviour();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    String time = DateFormat.jm().format(dateTime);
    String date = DateFormat.yMMMd().format(dateTime);
    return '$time, $date';
  }
}
