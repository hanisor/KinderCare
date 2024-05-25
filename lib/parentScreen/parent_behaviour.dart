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
    print("childrenList : $childrenList");
  }

  Future<void> fetchBehaviours() async {
    // Fetch behaviours for all children associated with the parent
    for (var child in childrenList) {
      RequestController req =
          RequestController(path: 'behaviour/by-childId/${child.childId}');
      print("child.childId : ${child.childId}");

      await req.get();
      var response = req.result();
      print("req result : $response"); // Print the response to see its type
      if (response != null && response.containsKey('behaviours')) {
        // Process the response data here
        var behaviourData = response['behaviours'];
        print(
            "behaviour Data: $behaviourData"); // Print behaviour data for debugging

        setState(() {
          behaviourList.addAll(List<BehaviourModel>.from(behaviourData.map((x) {
            x['id'] = int.tryParse(x['id'].toString());
            return BehaviourModel.fromJson(x);
          })));
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await fetchBehaviours();
  }

  @override
  void initState() {
    super.initState();
    fetchBehaviours(); // Fetch behaviours when the widget initializes
    getChildrenData();
  }

  // Group behaviours by month and then by child name
  Map<String, Map<String, List<BehaviourModel>>>
      _groupBehavioursByMonthAndName() {
    Map<String, Map<String, List<BehaviourModel>>> groupedData = {};

    for (var behaviour in behaviourList) {
      DateTime behaviourDate = DateTime.parse(behaviour.dateTime);
      String monthYear = DateFormat('MMMM yyyy').format(behaviourDate);
      String childName = childrenList
          .firstWhere((child) => child.childId == behaviour.childId)
          .childName;

      if (!groupedData.containsKey(monthYear)) {
        groupedData[monthYear] = {};
      }

      if (!groupedData[monthYear]!.containsKey(childName)) {
        groupedData[monthYear]![childName] = [];
      }

      groupedData[monthYear]![childName]!.add(behaviour);
    }

    // Add children who don't have any behaviour data
    for (var child in childrenList) {
      for (var monthYear in groupedData.keys) {
        if (!groupedData[monthYear]!.containsKey(child.childName)) {
          groupedData[monthYear]![child.childName] = [];
        }
      }
    }

    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, List<BehaviourModel>>> groupedData =
        _groupBehavioursByMonthAndName();

    return Scaffold(
      appBar: AppBar(
        title: Text('Behaviours'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: groupedData.keys.length,
                  itemBuilder: (context, index) {
                    String monthYear = groupedData.keys.elementAt(index);
                    Map<String, List<BehaviourModel>> childrenBehaviours =
                        groupedData[monthYear]!;
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ExpansionTile(
                        title: Text(
                          monthYear,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: childrenBehaviours.keys.map((childName) {
                          List<BehaviourModel> behaviours =
                              childrenBehaviours[childName]!;
                          return ExpansionTile(
                            title: Text(
                              childName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: behaviours.isNotEmpty
                                ? behaviours.map((behaviour) {
                                    return ListTile(
                                      title: Text(
                                        'Type: ${behaviour.type}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Description: ${behaviour.description}\nDate & Time: ${behaviour.dateTime}',
                                      ),
                                    );
                                  }).toList()
                                : [
                                    Padding(
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
