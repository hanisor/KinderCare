import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/model/performance_model.dart';
import 'package:kindercare/request_controller.dart';

class ParentPerformance extends StatefulWidget {
  final int? parentId;
  ParentPerformance({Key? key, this.parentId});
  @override
  State<ParentPerformance> createState() => _ParentPerformanceState();
}

class _ParentPerformanceState extends State<ParentPerformance> {
  List<ChildModel> childrenList = [];
  List<PerformanceModel> performanceList = []; // List to hold performances

  Future<void> getChildrenData() async {
    RequestController req =
        RequestController(path: 'child/by-guardianId/${widget.parentId}');
    await req.get();
    var response = req.result();
    print("req result : $response"); // Print the response to see its type
    if (response != null && response.containsKey('children')) {
      setState(() {
        var childrenData = response['children'];
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
                    childStatus: x['status'] as String,
                    parentId: widget.parentId,
                    performances: [],
                  )));
        } else {
          print("Invalid children data format"); // Debugging line
        }
      });
    } else {
      print("Failed to fetch children data"); // Debugging line
    }
    fetchPerformances();
    print("childrenList : $childrenList");
  }

  Future<void> fetchPerformances() async {
    for (var child in childrenList) {
      RequestController req =
          RequestController(path: 'performance/by-childId/${child.childId}');
      print("child.childId : ${child.childId}");

      await req.get();
      var response = req.result();
      print("req result : $response"); // Print the response to see its type
      if (response != null && response.containsKey('performances')) {
        // Process the response data here
        var performanceData = response['performances'];
        print(
            "performance Data: $performanceData"); // Print performance data for debugging

        setState(() {
          performanceList
              .addAll(List<PerformanceModel>.from(performanceData.map((x) {
            x['id'] = int.tryParse(x['id'].toString());
            return PerformanceModel.fromJson(x);
          })));
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await getChildrenData();
  }

  @override
  void initState() {
    super.initState();
    getChildrenData();
  }

  // Group performances by month and then by child name
  Map<String, Map<String, List<PerformanceModel>>>
      _groupPerformancesByMonthAndName() {
    Map<String, Map<String, List<PerformanceModel>>> groupedData = {};

    for (var child in childrenList) {
      // Ensure each month-year has an entry for each child, even if empty
      for (var performance in performanceList) {
        DateTime performanceDate = DateTime.parse(performance.date);
        String monthYear = DateFormat('yyyy-MM').format(performanceDate);

        if (!groupedData.containsKey(monthYear)) {
          groupedData[monthYear] = {};
        }

        if (!groupedData[monthYear]!.containsKey(child.childName)) {
          groupedData[monthYear]![child.childName] = [];
        }
      }

      // Add performances to the corresponding child and month-year
      for (var performance in performanceList) {
        if (performance.childId == child.childId) {
          DateTime performanceDate = DateTime.parse(performance.date);
          String monthYear = DateFormat('yyyy-MM').format(performanceDate);
          groupedData[monthYear]![child.childName]!.add(performance);
        }
      }
    }

    return groupedData;
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
    Map<String, Map<String, List<PerformanceModel>>> groupedData =
        _groupPerformancesByMonthAndName();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Report'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: groupedData.length,
          itemBuilder: (BuildContext context, int index) {
            String monthYear = groupedData.keys.elementAt(index);
            Map<String, List<PerformanceModel>> childrenPerformances =
                groupedData[monthYear]!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.pink[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ExpansionTile(
                  title: Text(
                    DateFormat('MMMM yyyy')
                        .format(DateTime.parse(monthYear + '-01')),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: childrenPerformances.entries.map((entry) {
                    String childName = entry.key;
                    List<PerformanceModel> performances = entry.value;

                    ChildModel child;
                    try {
                      child = childrenList
                          .firstWhere((c) => c.childName == childName);
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
                            '${child.childName} (Age: $childAge)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: performances.isEmpty
                              ? [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'No performance data available.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ]
                              : performances.map((performance) {
                                  return ListTile(
                                    title: Text(
                                      'Skill: ${performance.skill}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        for (int i = 0; i < 3; i++)
                                          Icon(
                                            i <
                                                    int.tryParse(
                                                        performance.level)!
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                          ),
                                      ],
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
