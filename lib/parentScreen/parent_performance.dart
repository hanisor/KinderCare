import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/model/performance_model.dart';
import 'package:kindercare/request_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ParentPerformance extends StatefulWidget {
  final int? parentId;
  ParentPerformance({Key? key, this.parentId});

  @override
  _ParentPerformanceState createState() => _ParentPerformanceState();
}

class _ParentPerformanceState extends State<ParentPerformance>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ChildModel> childrenList = [];
  List<PerformanceModel> performanceList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getChildrenData();
  }

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

  Map<String, Map<String, List<PerformanceModel>>>
      _groupPerformancesByMonthAndName() {
    Map<String, Map<String, List<PerformanceModel>>> groupedData = {};

    for (var child in childrenList) {
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

 Map<String, Map<String, Map<String, double>>> _calculateAverageLevels() {
  Map<String, Map<String, Map<String, double>>> averages = {};
  Map<String, Map<String, Map<String, List<int>>>> levels = {};

  DateTime now = DateTime.now();
  DateTime startOfCurrentYear = DateTime(now.year, 1, 1);
  DateTime startOfNextYear = DateTime(now.year + 1, 1, 1);
  DateTime endOfFirstSixMonths = DateTime(now.year, 6, 30, 23, 59, 59);
  DateTime startOfLastSixMonths = DateTime(now.year, 7, 1);

  for (var child in childrenList) {
    levels[child.childName] = {};

    for (var performance in performanceList) {
      if (performance.childId == child.childId) {
        if (!levels[child.childName]!.containsKey(performance.skill)) {
          levels[child.childName]![performance.skill] = {
            'firstSixMonths': [],
            'lastSixMonths': [],
          };
        }
        DateTime performanceDate = DateTime.parse(performance.date);

        String period = '';
        if (performanceDate.isAfter(startOfCurrentYear) &&
            performanceDate.isBefore(endOfFirstSixMonths)) {
          period = 'firstSixMonths';
        } else if (performanceDate.isAfter(startOfLastSixMonths) &&
                   performanceDate.isBefore(startOfNextYear)) {
          period = 'lastSixMonths';
        }

        if (period.isNotEmpty) {
          levels[child.childName]![performance.skill]![period]!
              .add(int.parse(performance.level));
        }
      }
    }
  }

  // Debug print levels to check data collection
  print('Levels: $levels');

  levels.forEach((childName, skills) {
    averages[childName] = {};
    skills.forEach((skill, periods) {
      double firstSixMonthsAverage = periods['firstSixMonths']!.isNotEmpty
          ? periods['firstSixMonths']!.reduce((a, b) => a + b) /
              periods['firstSixMonths']!.length
          : 0.0;
      double lastSixMonthsAverage = periods['lastSixMonths']!.isNotEmpty
          ? periods['lastSixMonths']!.reduce((a, b) => a + b) /
              periods['lastSixMonths']!.length
          : 0.0;

      averages[childName]![skill] = {
        'firstSixMonths': firstSixMonthsAverage,
        'lastSixMonths': lastSixMonthsAverage,
      };

      // Debug print to check calculated averages
      print('Child: $childName, Skill: $skill, First 6 Months Avg: $firstSixMonthsAverage, Last 6 Months Avg: $lastSixMonthsAverage');
    });
  });

  return averages;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Children Performance Report'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Monthly Report'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SixMonthReportView(
            childrenList: childrenList,
            performanceList: performanceList,
            refreshData: _refreshData,
            calculateAverageLevels: _calculateAverageLevels,
            calculateAge: _calculateAge,
          ),
          MonthlyReportView(
            childrenList: childrenList,
            performanceList: performanceList,
            refreshData: _refreshData,
            groupPerformancesByMonthAndName: _groupPerformancesByMonthAndName,
            calculateAge: _calculateAge,
          ),
        ],
      ),
    );
  }
}

class MonthlyReportView extends StatelessWidget {
  final List<ChildModel> childrenList;
  final List<PerformanceModel> performanceList;
  final Future<void> Function() refreshData;
  final Map<String, Map<String, List<PerformanceModel>>> Function()
      groupPerformancesByMonthAndName;
  final int Function(String) calculateAge;

  MonthlyReportView({
    required this.childrenList,
    required this.performanceList,
    required this.refreshData,
    required this.groupPerformancesByMonthAndName,
    required this.calculateAge,
  });

  Widget _buildStarRating(int level) {
    return Row(
      children: List.generate(3, (index) {
        return Icon(
          index < level ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var groupedData = groupPerformancesByMonthAndName();

    // Sort the keys (months) from newest to oldest
    var sortedKeys = groupedData.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView.builder(
        itemCount: sortedKeys.length,
        itemBuilder: (BuildContext context, int index) {
          var monthYear = sortedKeys[index];
          var childrenPerformances = groupedData[monthYear]!;

          return Card(
            color: Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ExpansionTile(
              title: Text(
                'Month: $monthYear',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: childrenPerformances.entries.map((entry) {
                String childName = entry.key;
                List<PerformanceModel> performances = entry.value;

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      '$childName (Age: ${calculateAge(childrenList.firstWhere((child) => child.childName == childName).childDOB)})',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: performances.map((performance) {
                      return ListTile(
                        title: Text(
                          'Skill: ${performance.skill}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${performance.date}'),
                            _buildStarRating(
                                int.parse(performance.level) > 3
                                    ? 3
                                    : int.parse(performance.level)), // Ensure max 3 stars
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}


class SixMonthReportView extends StatelessWidget {
  final List<ChildModel> childrenList;
  final List<PerformanceModel> performanceList;
  final Future<void> Function() refreshData;
  final Map<String, Map<String, Map<String, double>>> Function() calculateAverageLevels;
  final int Function(String) calculateAge;

  SixMonthReportView({
    required this.childrenList,
    required this.performanceList,
    required this.refreshData,
    required this.calculateAverageLevels,
    required this.calculateAge,
  });

  Map<String, Map<String, Map<int, double>>> _groupPerformancesByMonthAndSkill() {
    Map<String, Map<String, Map<int, double>>> groupedData = {};

    for (var child in childrenList) {
      for (var performance in performanceList) {
        if (performance.childId == child.childId) {
          DateTime performanceDate = DateTime.parse(performance.date);
          int month = performanceDate.month;

          if (!groupedData.containsKey(child.childName)) {
            groupedData[child.childName] = {};
          }
          if (!groupedData[child.childName]!.containsKey(performance.skill)) {
            groupedData[child.childName]![performance.skill] = {};
          }
          groupedData[child.childName]![performance.skill]![month] = double.parse(performance.level);
        }
      }
    }
    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, Map<int, double>>> groupedData = _groupPerformancesByMonthAndSkill();

    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView.builder(
        itemCount: childrenList.length,
        itemBuilder: (BuildContext context, int index) {
          var child = childrenList[index];
          var childPerformances = groupedData[child.childName] ?? {};

          return Card(
            color: Colors.pink[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ExpansionTile(
              title: Text(
                '${child.childName} (Age: ${calculateAge(child.childDOB)})',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: childPerformances.entries.map((entry) {
                String skill = entry.key;
                Map<int, double> monthlyLevels = entry.value;

                // Sort the monthly levels by month (key) in ascending order
                List<PerformanceData> chartData = monthlyLevels.entries
                    .map((entry) => PerformanceData(entry.key.toString(), entry.value))
                    .toList()
                  ..sort((a, b) => int.parse(a.month).compareTo(int.parse(b.month)));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'Skill: $skill',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildPerformanceChart(skill, chartData),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerformanceChart(String skill, List<PerformanceData> chartData) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(10),
      child: SfCartesianChart(
        title: ChartTitle(text: 'Performance Trend for $skill'),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'Month'),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Level'),
        ),
        series: <ChartSeries>[
          LineSeries<PerformanceData, String>(
            dataSource: chartData,
            xValueMapper: (PerformanceData data, _) => data.month,
            yValueMapper: (PerformanceData data, _) => data.level,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}


class PerformanceData {
  final String month;
  final double level;

  PerformanceData(this.month, this.level);
}