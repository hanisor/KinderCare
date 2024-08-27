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
  Map<String, Map<String, List<BehaviourModel>>> groupedBehaviourMap = {};

  @override
  void initState() {
    super.initState();
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
            groupedBehaviourMap.clear();

            childGroup.forEach((childGroupItem) {
              final child = childGroupItem['child'];
              final behaviours = child['behaviours'];
              final childModel = ChildModel.fromJson(child);
              final String childName = childModel.childName ?? 'Unknown Child';
              final String parentName =
                  childModel.guardian?.parentName ?? 'Unknown Parent';

              behaviours.forEach((behaviour) {
                BehaviourModel behaviourModel =
                    BehaviourModel.fromJson(behaviour, childModel: childModel);

                String month = DateFormat('yyyy-MM')
                    .format(DateTime.parse(behaviourModel.dateTime));

                if (groupedBehaviourMap[month] == null) {
                  groupedBehaviourMap[month] = {};
                }

                String key = '$childName - $parentName';

                if (groupedBehaviourMap[month]![key] == null) {
                  groupedBehaviourMap[month]![key] = [];
                }

                groupedBehaviourMap[month]![key]!.add(behaviourModel);
              });
            });

            // Sort the behaviours within each month and child group by date in ascending order
            groupedBehaviourMap.forEach((month, childBehaviours) {
              childBehaviours.forEach((childKey, behaviours) {
                behaviours.sort((a, b) => DateTime.parse(a.dateTime)
                    .compareTo(DateTime.parse(b.dateTime)));
              });
            });

            // Sort the groupedBehaviourMap by month in descending order
            groupedBehaviourMap = Map.fromEntries(groupedBehaviourMap.entries.toList()
              ..sort((a, b) => b.key.compareTo(a.key)));
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
        title: const Text('Behaviour Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
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
          Map<String, List<BehaviourModel>> childBehaviours =
              groupedBehaviourMap[month]!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.pink[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              shadowColor: Colors.pinkAccent,
              elevation: 5,
              child: ExpansionTile(
                title: Text(
                  DateFormat('MMMM yyyy').format(DateTime.parse(month + '-01')),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                    fontSize: 18.0,
                  ),
                ),
                iconColor: Colors.pinkAccent,
                children: childBehaviours.keys.map((childKey) {
                  List<BehaviourModel> behaviours = childBehaviours[childKey]!;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          childKey,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.pinkAccent,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Table(
                          border: TableBorder.all(
                            color: Colors.pinkAccent,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(3),
                            2: FlexColumnWidth(5),
                          },
                          children: [
                            TableRow(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Date',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Behaviour',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Description',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink),
                                ),
                              ),
                            ]),
                            ...behaviours.asMap().entries.map((entry) {
                              int i = entry.key;
                              BehaviourModel behaviour = entry.value;
                              return TableRow(
                                decoration: BoxDecoration(
                                  color: i % 2 == 0
                                      ? Colors.pink[50]
                                      : Colors.white,
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(DateFormat('yyyy-MM-dd')
                                        .format(DateTime.parse(
                                            behaviour.dateTime))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(behaviour.type),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(behaviour.description),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                      ],
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
