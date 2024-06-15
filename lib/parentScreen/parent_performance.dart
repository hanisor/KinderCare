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
                    childStatus:  x['status'] as String,
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
      RequestController req = RequestController(
          path: 'performance/by-childId/${child.childId}');
      print("child.childId : ${child.childId}");

      await req.get();
      var response = req.result();
      print("req result : $response"); // Print the response to see its type
      if (response != null && response.containsKey('performances')) {
        // Process the response data here
        var performanceData = response['performances'];
        print(
            "performance Data: $performanceData"); // Print performance data for debugging

        // Calculate the date 7 days ago
        DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

        setState(() {
          performanceList.addAll(List<PerformanceModel>.from(performanceData.map((x) {
            x['id'] = int.tryParse(x['id'].toString());
            return PerformanceModel.fromJson(x);
          })).where((performance) {
            DateTime performanceDate = DateTime.parse(performance.date);
            return performanceDate.isAfter(sevenDaysAgo);
          }).toList());
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
  Map<String, Map<String, List<PerformanceModel>>> _groupPerformancesByMonthAndName() {
    Map<String, Map<String, List<PerformanceModel>>> groupedData = {};

    for (var child in childrenList) {
      // Ensure each month-year has an entry for each child, even if empty
      for (var performance in performanceList) {
        DateTime performanceDate = DateTime.parse(performance.date);
        String monthYear = DateFormat('MMMM yyyy').format(performanceDate);

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
          String monthYear = DateFormat('MMMM yyyy').format(performanceDate);
          groupedData[monthYear]![child.childName]!.add(performance);
        }
      }
    }

    return groupedData;
  }

  int _calculateAge(String dob) {
    DateTime birthDate;
    try {
      birthDate = DateFormat('MM/dd/yyyy').parse(dob);
    } catch (e) {
      throw FormatException("Invalid date format");
    }
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
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
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: groupedData.keys.length,
                  itemBuilder: (context, index) {
                    String monthYear = groupedData.keys.elementAt(index);
                    Map<String, List<PerformanceModel>> childrenPerformances =
                        groupedData[monthYear]!;
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ExpansionTile(
                        title: Text(
                          monthYear,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: childrenPerformances.keys.map((childName) {
                          List<PerformanceModel> performances =
                              childrenPerformances[childName]!;
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
                          return ExpansionTile(
                            title: Text(
                              '$childName (Age: $childAge)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: performances.isNotEmpty
                                ? performances.map((performance) {
                                    return ListTile(
                                      title: Text(
                                        'Skill: ${performance.skill}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
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
                                        ],
                                      ),
                                    );
                                  }).toList()
                                : [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 4.0),
                                      child: Text(
                                        'No performance data available.',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
