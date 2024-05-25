import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:kindercare/caregiverScreen/caregiver_performance.dart';
import 'package:kindercare/model/performance_model.dart';
import 'package:kindercare/request_controller.dart';
import 'package:intl/intl.dart';

class CaregiverPerformanceReport extends StatefulWidget {
  final int? caregiverId;
  CaregiverPerformanceReport({Key? key, this.caregiverId});

  @override
  State<CaregiverPerformanceReport> createState() =>
      _CaregiverPerformanceReportState();
}

class _CaregiverPerformanceReportState
    extends State<CaregiverPerformanceReport> {
  Map<String, Map<String, Map<String, List<PerformanceModel>>>>
      performanceByMonthAndAge = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchChildPerformanceByCaregiverId();
  }

  Future<void> fetchChildPerformanceByCaregiverId() async {
    setState(() {
      isLoading = true;
    });

    try {
      RequestController req =
          RequestController(path: 'performance/${widget.caregiverId}');
      await req.get();
      var response = req.result();

      print("Raw response: $response"); // Debug statement

      if (response != null && response is Map<String, dynamic>) {
        final responseData = response;
        final childGroup = responseData['child_group'];

        print("Parsed child group: $childGroup"); // Debug statement

        setState(() {
          performanceByMonthAndAge.clear();

          if (childGroup is List) {
            for (var childGroupItem in childGroup) {
              final child = childGroupItem['child'];
              final performances = child['performances'];
              final dob = child['date_of_birth'];
              print("DOB: $dob");

              if (child != null &&
                  performances is List &&
                  dob != null &&
                  dob is String &&
                  dob.isNotEmpty) {
                try {
                  final childName = child['name'] as String?;
                  final age = _calculateAge(dob); // Pass the dob string

                  print("DOB: $dob, Age: $age");

                  for (var performance in performances) {
                    PerformanceModel performanceModel =
                        PerformanceModel.fromJson(performance);
                    performanceModel.childName = childName ?? 'Unknown Child';

                    final date = performanceModel.date;
                    if (date.isNotEmpty) {
                      final parsedDate = DateTime.parse(date);
                      final monthYear =
                          DateFormat('MMMM yyyy').format(parsedDate);
                      DateFormat('dd').format(parsedDate);

                      if (!performanceByMonthAndAge.containsKey(monthYear)) {
                        performanceByMonthAndAge[monthYear] = {};
                      }

                      if (!performanceByMonthAndAge[monthYear]!
                          .containsKey(age.toString())) {
                        performanceByMonthAndAge[monthYear]![age.toString()] =
                            {};
                      }

                      if (!performanceByMonthAndAge[monthYear]![age.toString()]!
                          .containsKey(childName)) {
                        performanceByMonthAndAge[monthYear]![age.toString()]![
                            childName!] = [];
                      }

                      performanceByMonthAndAge[monthYear]![age.toString()]![
                              childName]!
                          .add(performanceModel);
                    }
                  }
                } catch (e) {
                  print("Error processing child: $e");
                  continue; // Skip processing this child if an error occurs
                }
              }
            }
          }
        });
      } else {
        print('Failed to fetch child groups and performances');
      }
    } catch (error) {
      print('Failed to fetch child groups and performances: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  int _calculateAge(String dobString) {
    final dob = DateFormat('dd/MM/yyyy').parse(dobString);
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Report'),
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CaregiverPerformance(caregiverId: widget.caregiverId)),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchChildPerformanceByCaregiverId,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: performanceByMonthAndAge.keys.length,
                itemBuilder: (context, index) {
                  final monthYear =
                      performanceByMonthAndAge.keys.elementAt(index);
                  final performancesByAge =
                      performanceByMonthAndAge[monthYear] ?? {};

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.pink[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          monthYear,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: performancesByAge.keys.map((age) {
                          final performancesByChild =
                              performancesByAge[age.toString()] ?? {};

                          // Sort the children by day of the month
                          final sortedChildren = performancesByChild.keys
                              .toList()
                            ..sort((a, b) {
                              final firstDate = DateTime.parse(
                                  performancesByChild[a]!.first.date);
                              final secondDate = DateTime.parse(
                                  performancesByChild[b]!.first.date);
                              return firstDate.day.compareTo(secondDate.day);
                            });

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
                                children: sortedChildren.map((childName) {
                                  final performances =
                                      performancesByChild[childName]!;
                                  performances.sort((a, b) =>
                                      DateTime.parse(a.date)
                                          .compareTo(DateTime.parse(b.date)));
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: ExpansionTile(
                                        title: Text(childName),
                                        children: performances.map((performance) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(performance.date))}'),
                                                Text('Skill: ${performance.skill}'),
                                                RatingBarIndicator(
                                                  rating: double.tryParse(
                                                          performance.level) ??
                                                      0,
                                                  itemBuilder:
                                                      (context, index) => Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  itemCount: 5,
                                                  itemSize: 20.0,
                                                  direction: Axis.horizontal,
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
      ),
    );
  }
}
