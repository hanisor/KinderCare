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

  // Summary data for the first tab
  Map<String, Map<String, Map<String, int>>> summaryBehaviourMap = {};

  // Grouped data for the detailed tab
  Map<String, Map<String, Map<String, List<BehaviourModel>>>> groupedBehaviourMap = {};
  String selectedMonthYear = '';
  List<String> availableMonths = [];

  // New variables for child selection
  String selectedChildName = '';
  List<String> availableChildren = [];

  Future<void> getChildrenData() async {
    // Fetch children and update availableChildren list
    RequestController req = RequestController(path: 'child/by-guardianId/${widget.parentId}');
    await req.get();
    var response = req.result();
    if (response != null && response.containsKey('children')) {
      setState(() {
        var childrenData = response['children'];
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
        }
        // Populate available children names
        availableChildren = childrenList.map((child) => child.childName).toList();
        selectedChildName = availableChildren.isNotEmpty ? availableChildren.first : '';
      });
      await fetchBehaviours();
    }
  }
  Future<void> fetchBehaviours() async {
    for (var child in childrenList) {
      RequestController req = RequestController(path: 'behaviour/by-childId/${child.childId}');
      await req.get();
      var response = req.result();
      if (response != null && response.containsKey('behaviours')) {
        var behaviourData = response['behaviours'];
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
    _populateAvailableMonths();
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
      DateTime behaviourDate = DateTime.parse(behaviour.dateTime);
      String monthYear = DateFormat('yyyy-MM').format(behaviourDate);
      String day = DateFormat('yyyy-MM-dd').format(behaviourDate);
      ChildModel child = childrenList.firstWhere((child) => child.childId == behaviour.childId);
      String childName = child.childName;

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

  void _populateAvailableMonths() {
  setState(() {
    availableMonths = groupedBehaviourMap.keys.toList();
    // Sort the months in descending order
    availableMonths.sort((a, b) => b.compareTo(a));
    // Select the most recent month
    selectedMonthYear = availableMonths.isNotEmpty ? availableMonths.first : '';
  });
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
    return Column(
      children: [
        if (availableChildren.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedChildName,
              items: availableChildren.map((String childName) {
                return DropdownMenuItem<String>(
                  value: childName,
                  child: Text(childName),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedChildName = newValue!;
                  // Populate available months based on selected child
                  _populateAvailableMonthsForSelectedChild();
                });
              },
            ),
          ),
        if (availableMonths.isNotEmpty && selectedChildName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedMonthYear,
              items: availableMonths.map((String monthYear) {
                return DropdownMenuItem<String>(
                  value: monthYear,
                  child: Text(DateFormat('MMMM yyyy').format(DateTime.parse(monthYear + '-01'))),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedMonthYear = newValue!;
                });
              },
            ),
          ),
        Expanded(
          child: _buildBehaviourTable(),
        ),
      ],
    );
  }

  void _populateAvailableMonthsForSelectedChild() {
    setState(() {
      availableMonths = [];
      selectedMonthYear = '';

      if (groupedBehaviourMap.isNotEmpty && selectedChildName.isNotEmpty) {
        availableMonths = groupedBehaviourMap.keys.where((monthYear) {
          return groupedBehaviourMap[monthYear]!.values.any((dayMap) =>
              dayMap.keys.any((childName) => childName == selectedChildName));
        }).toList();

        availableMonths.sort((a, b) => b.compareTo(a));
        selectedMonthYear = availableMonths.isNotEmpty ? availableMonths.first : '';
      }
    });
  }

  Widget _buildBehaviourTable() {
    if (selectedMonthYear.isEmpty) {
      return Center(child: Text('No data available for the selected month.'));
    }

    Map<String, Map<String, List<BehaviourModel>>>? dailyMap = groupedBehaviourMap[selectedMonthYear];

    if (dailyMap == null || dailyMap.isEmpty) {
      return Center(child: Text('No data available for the selected month.'));
    }

    DateTime firstDayOfMonth = DateTime.parse(selectedMonthYear + '-01');
    DateTime lastDayOfMonth = DateTime(firstDayOfMonth.year, firstDayOfMonth.month + 1, 0);
    List<String> allDays = List.generate(lastDayOfMonth.day, (index) {
      return DateFormat('yyyy-MM-dd').format(DateTime(firstDayOfMonth.year, firstDayOfMonth.month, index + 1));
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FixedColumnWidth(150.0),
            1: FixedColumnWidth(150.0),
            2: FixedColumnWidth(250.0),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.green[100]),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            for (String day in allDays) ...[
              if (dailyMap.containsKey(day) && dailyMap[day]!.containsKey(selectedChildName))
                for (var behaviour in dailyMap[day]![selectedChildName]!) 
                  TableRow(
                    decoration: BoxDecoration(color: Colors.green[50]),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(DateFormat('dd MMMM yyyy').format(DateTime.parse(day))),
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
                  ),
            
                TableRow(
                  decoration: BoxDecoration(color: Colors.red[50]),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(DateFormat('dd MMMM yyyy').format(DateTime.parse(day))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('No Record', style: TextStyle(color: Colors.red)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('No Record', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
            ],
          ],
        ),
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
