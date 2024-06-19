import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/behaviour_model.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/request_controller.dart';

class ParentBehaviour extends StatefulWidget {
  final int? parentId;
  ParentBehaviour({Key? key, this.parentId});
  @override
  State<ParentBehaviour> createState() => _ParentBehaviourState();
}

class _ParentBehaviourState extends State<ParentBehaviour> {
  List<ChildModel> childrenList = [];
  List<BehaviourModel> behaviourList = []; // List to hold checklist items
  Map<String, Map<String, Map<String, List<BehaviourModel>>>> groupedBehaviourMap = {};

  Future<void> getChildrenData() async {
    RequestController req = RequestController(path: 'child/by-guardianId/${widget.parentId}');
    await req.get();
    var response = req.result();
    print("req result : $response"); // Print the response to see its type
    if (response != null && response.containsKey('children')) {
      setState(() {
        var childrenData = response['children'];
        print("Children Data: $childrenData"); // Debugging line
        if (childrenData is List) {
          childrenList = List<ChildModel>.from(childrenData.map((x) => ChildModel(
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
          print("Invalid children data format"); // Debugging line
        }
      });
      // Fetch behaviours after children data has been fetched
      await fetchBehaviours();
    } else {
      print("Failed to fetch children data"); // Debugging line
    }
    print("childrenList : $childrenList");
  }

  Future<void> fetchBehaviours() async {
    // Fetch behaviours for all children associated with the parent
    for (var child in childrenList) {
      RequestController req = RequestController(path: 'behaviour/by-childId/${child.childId}');
      print("child.childId : ${child.childId}");

      await req.get();
      var response = req.result();
      print("req result : $response"); // Print the response to see its type
      if (response != null && response.containsKey('behaviours')) {
        // Process the response data here
        var behaviourData = response['behaviours'];
        print("behaviour Data: $behaviourData"); // Print behaviour data for debugging

        setState(() {
          behaviourList.addAll(List<BehaviourModel>.from(behaviourData.map((x) {
            x['id'] = int.tryParse(x['id'].toString());
            return BehaviourModel.fromJson(x);
          })));
        });
      }
    }
    _groupBehavioursByMonthDayAndName();
  }

  void _groupBehavioursByMonthDayAndName() {
    groupedBehaviourMap.clear();

    for (var behaviour in behaviourList) {
      DateTime behaviourDate;
      try {
        behaviourDate = DateTime.parse(behaviour.dateTime);
      } catch (e) {
        print("Invalid behaviour date format: ${behaviour.dateTime}");
        continue;
      }
      String monthYear = DateFormat('yyyy-MM').format(behaviourDate);
      String day = DateFormat('yyyy-MM-dd').format(behaviourDate);
      ChildModel child;
      try {
        child = childrenList.firstWhere((child) => child.childId == behaviour.childId);
      } catch (e) {
        print("Child not found for behaviour: ${behaviour.childId}");
        continue;
      }
      String childName = child.childName;
      String childDOB = child.childDOB;
      // ignore: unused_local_variable
      int childAge;
      try {
        childAge = _calculateAge(childDOB);
      } catch (e) {
        print("Invalid child DOB format: $childDOB");
        continue;
      }

      if (!groupedBehaviourMap.containsKey(monthYear)) {
        groupedBehaviourMap[monthYear] = {};
      }
      if (!groupedBehaviourMap[monthYear]!.containsKey(day)) {
        groupedBehaviourMap[monthYear]![day] = {};
      }
      if (!groupedBehaviourMap[monthYear]![day]!.containsKey(childName)) {
        groupedBehaviourMap[monthYear]![day]![childName] = [];
      }

      groupedBehaviourMap[monthYear]![day]![childName]!.add(behaviour);
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

  Future<void> _refreshData() async {
    await getChildrenData();
  }

  @override
  void initState() {
    super.initState();
    getChildrenData(); // Fetch children data when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Behaviour Report'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: groupedBehaviourMap.length,
          itemBuilder: (BuildContext context, int index) {
            String month = groupedBehaviourMap.keys.elementAt(index);
            Map<String, Map<String, List<BehaviourModel>>> dayGroupMap = groupedBehaviourMap[month]!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.pink[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ExpansionTile(
                  title: Text(
                    DateFormat('MMMM yyyy').format(DateTime.parse(month + '-01')),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: dayGroupMap.entries.map((dayEntry) {
                    String date = dayEntry.key;
                    Map<String, List<BehaviourModel>> nameGroupMap = dayEntry.value;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.green[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            DateFormat('dd MMMM yyyy').format(DateTime.parse(date)),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: nameGroupMap.entries.map((nameEntry) {
                            String childName = nameEntry.key;
                            List<BehaviourModel> behaviours = nameEntry.value;
                            ChildModel child;
                            try {
                              child = childrenList.firstWhere((child) => child.childName == childName);
                            } catch (e) {
                              print("Child not found for name: $childName");
                              return Container();
                            }
                            int childAge;
                            try {
                              childAge = _calculateAge(child.childDOB);
                            } catch (e) {
                              print("Invalid child DOB format: ${child.childDOB}");
                              return Container();
                            }
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: Colors.blue[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    '$childName (Age: $childAge)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: behaviours.map((behaviour) {
                                    return ListTile(
                                      title: Text(
                                        'Type: ${behaviour.type}',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Description: ${behaviour.description}\nDate & Time: ${behaviour.dateTime}',
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
