import 'package:flutter/material.dart';
import 'package:kindercare/caregiverScreen/caregiver_behaviour.dart';
import 'package:kindercare/model/behaviour_model.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/request_controller.dart';
import 'package:intl/intl.dart';

class CaregiverBehaviourReport extends StatefulWidget {
  final int? caregiverId;
  CaregiverBehaviourReport({Key? key, this.caregiverId});

  @override
  State<CaregiverBehaviourReport> createState() =>
      _CaregiverBehaviourReportState();
}

class _CaregiverBehaviourReportState extends State<CaregiverBehaviourReport> {
  List<BehaviourModel> behaviourList = [];
  Map<String, Map<String, Map<int, List<BehaviourModel>>>> groupedBehaviourMap = {};

  @override
  void initState() {
    super.initState();
    // Fetch child behaviours when the widget initializes
    fetchChildBehavioursByCaregiverId();
  }

  Future<void> fetchChildBehavioursByCaregiverId() async {
    try {
      RequestController req =
          RequestController(path: 'behaviour/${widget.caregiverId}');
      await req.get();
      var response = req.result();

      if (response != null) {
        if (response is Map<String, dynamic>) {
          final responseData = response as Map<String, dynamic>;
          final childGroup = responseData['child_group'];

          setState(() {
            behaviourList.clear();
            groupedBehaviourMap.clear();

            childGroup.forEach((childGroupItem) {
              final child = childGroupItem['child'];
              final behaviours = child['behaviours'];
              final childModel = ChildModel.fromJson(child);

              behaviours.forEach((behaviour) {
                BehaviourModel behaviourModel =
                    BehaviourModel.fromJson(behaviour, childModel: childModel);

                String date = DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse(behaviourModel.dateTime));
                String month = DateFormat('yyyy-MM').format(DateTime.parse(behaviourModel.dateTime));
                final dateOfBirthString = child['date_of_birth'];
                if (dateOfBirthString != null) {
                  try {
                    final dob =
                        DateFormat('yyyy-MM-dd').parse(dateOfBirthString);
                    final now = DateTime.now();
                    final age = now.year -
                        dob.year -
                        (now.month >= dob.month && now.day >= dob.day ? 0 : 1);

                    if (groupedBehaviourMap[month] == null) {
                      groupedBehaviourMap[month] = {};
                    }
                    if (groupedBehaviourMap[month]![date] == null) {
                      groupedBehaviourMap[month]![date] = {};
                    }
                    if (groupedBehaviourMap[month]![date]![age] == null) {
                      groupedBehaviourMap[month]![date]![age] = [];
                    }
                    groupedBehaviourMap[month]![date]![age]!.add(behaviourModel);
                  } catch (_) {
                    try {
                      final dob =
                          DateFormat('MM/dd/yyyy').parse(dateOfBirthString);
                      final now = DateTime.now();
                      final age = now.year -
                          dob.year -
                          (now.month >= dob.month && now.day >= dob.day
                              ? 0
                              : 1);

                      if (groupedBehaviourMap[month] == null) {
                        groupedBehaviourMap[month] = {};
                      }
                      if (groupedBehaviourMap[month]![date] == null) {
                        groupedBehaviourMap[month]![date] = {};
                      }
                      if (groupedBehaviourMap[month]![date]![age] == null) {
                        groupedBehaviourMap[month]![date]![age] = [];
                      }
                      groupedBehaviourMap[month]![date]![age]!.add(behaviourModel);
                    } catch (error) {
                      print('Invalid date of birth format: $dateOfBirthString');
                    }
                  }
                }
              });
            });
          });
        } else {
          print(
              'Failed to fetch child groups and behaviours: ${response.toString()}');
        }
      } else {
        print('No response received');
      }
    } catch (error) {
      print('Failed to fetch child groups and behaviours: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Behaviour Report',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CaregiverBehaviour(caregiverId: widget.caregiverId)),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groupedBehaviourMap.length,
        itemBuilder: (BuildContext context, int index) {
          String month = groupedBehaviourMap.keys.elementAt(index);
          Map<String, Map<int, List<BehaviourModel>>> dayGroupMap =
              groupedBehaviourMap[month]!;
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
                  Map<int, List<BehaviourModel>> ageGroupMap = dayEntry.value;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.green[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          date,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: ageGroupMap.entries.map((entry) {
                          int age = entry.key;
                          List<BehaviourModel> behaviours = entry.value;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              color: Colors.blue[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  'Age: $age',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                children: behaviours.map((behaviour) {
                                  return ListTile(
                                    title: Text(
                                      behaviour.childName ?? 'Unknown Child',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Parent Name: ${behaviour.childModel?.guardian?.parentName ?? 'Unknown Parent'}', // Display parentModel name
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Behaviour: ${behaviour.type}',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Description: ${behaviour.description}',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Time: ${DateFormat('HH:mm').format(DateTime.parse(behaviour.dateTime))}',
                                          style: TextStyle(fontWeight: FontWeight.bold),
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
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
