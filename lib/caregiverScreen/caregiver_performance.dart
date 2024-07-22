import 'package:flutter/material.dart';
import 'package:kindercare/caregiverScreen/caregiver_performanceReport.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/model/performance_model.dart';
import 'package:kindercare/request_controller.dart';
import 'package:intl/intl.dart';

class CaregiverPerformance extends StatefulWidget {
  final int? caregiverId;
  CaregiverPerformance({Key? key, this.caregiverId});

  @override
  State<CaregiverPerformance> createState() => _CaregiverPerformanceState();
}

class _CaregiverPerformanceState extends State<CaregiverPerformance> {
  int? level;
  DateTime? date;
  int? selectedAge;
  List<ChildModel> childrenList = [];
  ChildModel? selectedChild;
  String? selectedSkill;
  Map<int, List<ChildModel>> childrenByAge = {};
  Map<String, int?> skillLevels = {};
  Map<int, List<String>> skillsByAge = {
    2: [
      'Language Development',
      'Gross Motor Skills',
      'Fine Motor Skills',
      'Social Interaction'
    ],
    3: [
      'Pre-Literacy Skills',
      'Numeracy Skills',
      'Self-Help Skills',
      'Emotional Awareness'
    ],
    4: [
      'Language Fluency',
      'Early Writing Skills',
      'Problem-Solving Abilities',
      'Social Play'
    ],
    5: [
      'Reading Readiness',
      'Mathematical Thinking',
      'Critical Thinking',
      'Physical Coordination'
    ],
    6: [
      'Reading Fluency',
      'Critical Thinking and Problem Solving',
      'Social and Emotional Development',
      'Physical Skills'
    ]
  };

  final _formKey = GlobalKey<FormState>();

  DateTime? parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      print("Invalid date format: $dateString");
      return null;
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
  print("Fetching children data for groupId: $groupId"); // Debugging line

  try {
    RequestController req = RequestController(path: 'child-group/caregiverId/$groupId');
    await req.get();
    var response = req.result();
    print("Request result: $response"); // Print the response to see its type

    if (response != null && response.containsKey('group')) {
      setState(() {
        var childrenData = response['group'];
        print("Children Data: $childrenData"); // Debugging line

        if (childrenData is List) {
          List<ChildModel> allChildrenList = List<ChildModel>.from(childrenData.map((x) => ChildModel(
                childId: int.tryParse(x['id']?.toString() ?? '0') ?? 0,
                childName: x['name'] as String? ?? '',
                childDOB: x['date_of_birth'] as String? ?? '',
                childGender: x['gender'] as String? ?? '',
                childMykidNumber: x['my_kid_number'] as String? ?? '',
                childAllergies: x['allergy'] as String? ?? '',
                childStatus: x['status'] as String? ?? '',
                parentId: int.tryParse(x['guardian_id']?.toString() ?? '0') ?? 0,
                performances: x['performances'] != null && x['performances'] is List
                    ? List<PerformanceModel>.from((x['performances'] as List).map((e) => PerformanceModel.fromJson(e as Map<String, dynamic>)))
                    : [],
              )));

          // Group children by age
          childrenByAge.clear();
          allChildrenList.forEach((child) {
            try {
              DateTime? dob = parseDate(child.childDOB);
              if (dob != null) {
                int age = _calculateAge(child.childDOB); // Calculate age here
                if (!childrenByAge.containsKey(age)) {
                  childrenByAge[age] = [];
                }
                childrenByAge[age]!.add(child);
              }
            } catch (e) {
              print("Invalid date format for child: ${child.childName}, DOB: ${child.childDOB}"); // Debugging line
            }
          });

          // Debugging lines
          childrenByAge.forEach((age, children) {
            print('Age $age: ${children.map((c) => c.childName).toList()}');
          });
        } else {
          print("Invalid children data format"); // Debugging line
        }
      });
    } else {
      print("Failed to fetch children data or key 'child_group' not found"); // Debugging line
    }
  } catch (e) {
    print("Error during network request: $e");
  }
}


  // Method to add performance
  Future<void> addPerformance() async {
    try {
      if (date == null || selectedChild == null) {
        return;
      }

      RequestController req = RequestController(path: 'add-performance');

      // Format the DateTime object into a string
      String formattedDate = DateFormat('yyyy-MM-dd').format(date!);

      // Iterate through the map to add each skill, level, date, and child ID
      for (var entry in skillLevels.entries) {
        String skill = entry.key;
        int? level = entry.value;

        if (level != null) {
          req.setBody({
            "skill": skill,
            "level": level.toString(),
            "date": formattedDate,
            "child_id": selectedChild!.childId.toString(),
          });

          var response = await req.post();

          if (response.statusCode == 200) {
            var result = req.result();

            if (result != null) {
              print('Performance data saved successfully');
            } else {
              print('Error saving performance data');
            }
          } else {
            print(
                'Error: HTTP request failed with status code ${response.statusCode}');
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget buildSkillsCard() {
    if (selectedChild == null) {
      print('Selected child or childDOB is null.');
      return SizedBox.shrink();
    }

    print('Selected child: ${selectedChild!.childName}');
    print('Selected child DOB: ${selectedChild!.childDOB}');

    final age = _calculateAge(selectedChild!.childDOB);
    if (age == -1) {
      return Text('Invalid date of birth.');
    }

    print('Calculated age: $age');

    final selectedSkills = skillsByAge[age];
    if (selectedSkills == null) {
      print('No skills found for age $age.');
      return SizedBox.shrink();
    }

    print('Selected skills for age $age: $selectedSkills');

    // Group performances by date
    Map<String, List<Map<String, dynamic>>> performancesByDate = {};
    for (var performance in selectedChild!.performances) {
      String date = performance.date; // Assuming performance has a date field
      if (!performancesByDate.containsKey(date)) {
        performancesByDate[date] = [];
      }
      performancesByDate[date]!.add({
        'skill': performance.skill, // Assuming performance has a skill field
        'level': performance.level, // Assuming performance has a level field
      });
    }

    // Create a list of widgets for each date and its performances
    List<Widget> performanceWidgets = [];
    performancesByDate.forEach((date, performances) {
      performanceWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(
            date,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );

      for (var performance in performances) {
        performanceWidgets.add(
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(performance['skill']),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    3,
                    (index) => Icon(
                      Icons.star,
                      color: performance['level'] != null &&
                              performance['level'] >= index + 1
                          ? Colors.yellow
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });

    // Create a list of skill rating widgets with clickable stars
    List<Widget> skillWidgets = selectedSkills.map((skill) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(skill),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(3, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      skillLevels[skill] = index + 1;
                    });
                  },
                  child: Icon(
                    Icons.star,
                    color: skillLevels[skill] != null &&
                            skillLevels[skill]! >= index + 1
                        ? Colors.amber
                        : Colors.grey,
                  ),
                );
              }),
            ),
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...performanceWidgets,
            Divider(),
            ...skillWidgets,
          ],
        ),
      ),
    );
  }

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Performance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          date = DateTime(picked.year, picked.month,
                              picked.day); // Strip the time part
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text(
                          date == null
                              ? 'Choose Date'
                              : DateFormat('yyyy-MM-dd').format(date!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (childrenByAge.isNotEmpty) ...[
                DropdownButton<int>(
                  hint: Text('Select age group'),
                  items: childrenByAge.keys.map((int age) {
                    return DropdownMenuItem<int>(
                      value: age,
                      child: Text('Age $age'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedAge = newValue;
                      childrenList = childrenByAge[newValue] ?? [];
                      selectedChild = null; // Reset the selected child when age group changes
                    });
                  },
                  value: selectedAge, // Display the selected age
                ),
                SizedBox(height: 20),
              ],
              if (selectedAge != null && childrenList.isNotEmpty) ...[
                // Dropdown for selecting child
                DropdownButton<ChildModel>(
                  hint: Text('Select child'),
                  items: childrenList.map((ChildModel child) {
                    return DropdownMenuItem<ChildModel>(
                      value: child,
                      child: Text(child.childName),
                    );
                  }).toList(),
                  onChanged: (ChildModel? newValue) {
                    setState(() {
                      selectedChild = newValue;
                    });
                  },
                  value: selectedChild,
                ),
                SizedBox(height: 20),
              ],
              // Skills card
              if (selectedChild != null) buildSkillsCard(),
              SizedBox(height: 20),
              // Date picker

              SizedBox(height: 20),
              // Submit button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      addPerformance();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CaregiverPerformanceReport(
                                caregiverId: widget.caregiverId)),
                      );
                    }
                  },
                  child: Text('Add Performance'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}