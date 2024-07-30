import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
  List<BehaviourModel> behaviourList = [];

  // Summary data for first tab
  Map<String, Map<String, Map<String, int>>> summaryBehaviourMap = {};

  // Grouped data for second tab
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
      await fetchBehaviours();
    } else {
      print("Failed to fetch children data"); // Debugging line
    }
    print("childrenList : $childrenList");
  }

  Future<void> fetchBehaviours() async {
    for (var child in childrenList) {
      RequestController req = RequestController(path: 'behaviour/by-childId/${child.childId}');
      print("child.childId : ${child.childId}");

      await req.get();
      var response = req.result();
      print("req result : $response"); // Print the response to see its type
      if (response != null && response.containsKey('behaviours')) {
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
    _summarizeBehaviours();
    _groupBehavioursByMonthDayAndName();
  }

  void _summarizeBehaviours() {
    summaryBehaviourMap.clear();

    for (var behaviour in behaviourList) {
      DateTime behaviourDate = DateTime.parse(behaviour.dateTime);
      String monthYear = DateFormat('yyyy-MM').format(behaviourDate);
      ChildModel child = childrenList.firstWhere((child) => child.childId == behaviour.childId);
      String childName = child.childName;
      String behaviourType = behaviour.type;

      if (!summaryBehaviourMap.containsKey(childName)) {
        summaryBehaviourMap[childName] = {};
      }
      if (!summaryBehaviourMap[childName]!.containsKey(monthYear)) {
        summaryBehaviourMap[childName]![monthYear] = {};
      }
      if (!summaryBehaviourMap[childName]![monthYear]!.containsKey(behaviourType)) {
        summaryBehaviourMap[childName]![monthYear]![behaviourType] = 0;
      }

      summaryBehaviourMap[childName]![monthYear]![behaviourType] =
          summaryBehaviourMap[childName]![monthYear]![behaviourType]! + 1;
    }
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
      return -1;
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Behaviour Report'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Detailed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSummaryTab(),
            _buildDetailedTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        itemCount: summaryBehaviourMap.length,
        itemBuilder: (BuildContext context, int index) {
          String childName = summaryBehaviourMap.keys.elementAt(index);
          Map<String, Map<String, int>> monthGroupMap = summaryBehaviourMap[childName]!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                ...monthGroupMap.entries.map((monthEntry) {
                  String month = monthEntry.key;
                  Map<String, int> typeGroupMap = monthEntry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      color: Colors.green[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              DateFormat('MMMM yyyy').format(DateTime.parse(month + '-01')),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: SfCircularChart(
                              series: <CircularSeries>[
                                PieSeries<BehaviourTypeCount, String>(
                                  dataSource: _createSampleData(typeGroupMap),
                                  xValueMapper: (BehaviourTypeCount data, _) => data.type,
                                  yValueMapper: (BehaviourTypeCount data, _) => data.count,
                                  dataLabelMapper: (BehaviourTypeCount data, _) => '${data.type}: ${data.count}',
                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailedTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        itemCount: groupedBehaviourMap.length,
        itemBuilder: (BuildContext context, int index) {
          String monthYear = groupedBehaviourMap.keys.elementAt(index);
          Map<String, Map<String, List<BehaviourModel>>> dayGroupMap = groupedBehaviourMap[monthYear]!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(DateTime.parse(monthYear + '-01')),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                ...dayGroupMap.entries.map((dayEntry) {
                  String day = dayEntry.key;
                  Map<String, List<BehaviourModel>> childGroupMap = dayEntry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      color: Colors.blue[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          DateFormat('dd MMM yyyy').format(DateTime.parse(day)),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          ...childGroupMap.entries.map((childEntry) {
                            String childName = childEntry.key;
                            List<BehaviourModel> behaviours = childEntry.value;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    childName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  ...behaviours.map((behaviour) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Card(
                                        color: Colors.white,
                                        child: ListTile(
                                          title: Text(behaviour.type),
                                          subtitle: Text(behaviour.description),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  List<BehaviourTypeCount> _createSampleData(Map<String, int> typeGroupMap) {
    return typeGroupMap.entries
        .map((entry) => BehaviourTypeCount(type: entry.key, count: entry.value))
        .toList();
  }
}

class BehaviourTypeCount {
  final String type;
  final int count;

  BehaviourTypeCount({required this.type, required this.count});
}
