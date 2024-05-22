import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/behaviour_model.dart';
import 'package:kindercare/model/child_model.dart';
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
  List<BehaviourModel> behaviourList = []; // List to hold checklist items
  ChildModel? selectedChild; // Initialize selectedChild
  List<ChildModel> childrenList = [];
  List<String> emotionTypes = ['Happy', 'Sad', 'Angry', 'Excited', 'Calm'];

  @override
  void initState() {
    super.initState();
    getChildrenData(); // Call the function when the widget is initialized
    dateTime = DateTime.now(); // Initialize dateTime with current date and time
  }

  Future<void> getChildrenData() async {
    print(
        "Fetching children data for caregiverId: ${widget.caregiverId}"); // Debugging line

    try {
      RequestController req = RequestController(
          path: 'child-group/caregiverId/${widget.caregiverId}');
      await req.get();
      var response = req.result();
      print("Request result: $response"); // Print the response to see its type

      if (response != null && response.containsKey('child_group')) {
        setState(() {
          var childrenData = response['child_group'];
          print("Children Data: $childrenData"); // Debugging line

          if (childrenData is List) {
            childrenList =
                List<ChildModel>.from(childrenData.map((x) => ChildModel(
                      childId: int.tryParse(x['id'].toString()),
                      childName: x['name'] as String,
                      childDOB: x['date_of_birth'] as String,
                      childGender: x['gender'] as String,
                      childMykidNumber: x['my_kid_number'] as String,
                      childAllergies: x['allergy'] as String,
                      parentId: int.tryParse(x['guardian_id'].toString()), 
                      performances: [],
                    )));

            // Set selectedChild if the list is not empty
            if (childrenList.isNotEmpty) {
              selectedChild = childrenList[0];
              print(
                  'Selected child dataaaa: ${selectedChild!.childId.toString()}');
            }
          } else {
            print("Invalid children data format"); // Debugging line
          }
        });
      } else {
        print(
            "Failed to fetch children data or key 'child_group' not found"); // Debugging line
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

      // Debugging: Print the values of type, description, dateTime, and selectedChild
      print('Type: $type');
      print('Description: $description');
      print('Date & Time: $dateTime');
      print('Selected Child: ${selectedChild!.childId}');

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
          print('Checklist item saved successfully');
        } else {
          print('Error saving checklist item');
        }
      } else {
        print(
            'Error: HTTP request failed with status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _refreshData() async {
    await getChildrenData();
  }

  // Function to calculate age from date of birth
  String _calculateAge(String dateOfBirth) {
    try {
      DateTime dob = DateFormat("dd/MM/yyyy").parse(dateOfBirth);
      DateTime today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      print("Error parsing date of birth: $e");
      return "Unknown";
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Behaviour'),
    ),
    body: RefreshIndicator(
      onRefresh: _refreshData,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButton(
              hint: const Text(
                "Select Child ",
                style: TextStyle(
                  color: Colors.pink, // Pink text color
                ),
              ),
              value: selectedChild?.childName,
              icon: const Icon(
                Icons.arrow_drop_down, // Arrow icon
                color: Colors.pink, // Pink color
              ),
              elevation: 4,
              style: const TextStyle(
                color: Colors.pink, // Pink text color
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              underline: Container(
                height: 2,
                color: Colors.pink, // Pink underline
              ),
              items: childrenList.map<DropdownMenuItem<String>>((child) {
                return DropdownMenuItem<String>(
                  value: child.childName,
                  child: Text(
                    child.childName,
                    style: const TextStyle(
                      color: Colors.black, // Black text color
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
              Text(
                "Child Age: ${_calculateAge(selectedChild!.childDOB)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              hint: const Text(
                "Select Emotion",
                style: TextStyle(
                  color: Colors.pink, // Pink text color
                ),
              ),
              value: type,
              icon: const Icon(
                Icons.arrow_drop_down, // Arrow icon
                color: Colors.pink, // Pink color
              ),
              elevation: 4,
              style: const TextStyle(
                color: Colors.pink, // Pink text color
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
                      color: Colors.black, // Black text color
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
    ),
  );
}

  String _formatDateTime(DateTime dateTime) {
    String time = DateFormat.jm().format(dateTime);
    String date = DateFormat.yMMMd().format(dateTime);
    return '$time, $date';
  }
}
