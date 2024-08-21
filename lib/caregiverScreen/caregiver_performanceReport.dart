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
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Report'),
        actions: [
          IconButton(
            icon: Icon(Icons.playlist_add),
            onPressed: () {
              print(
                  "Navigating to CaregiverPerformance with caregiverId: ${widget.caregiverId}"); // Debugging line

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
                  // Sort the keys (monthYear) in reverse order to display the latest month first
                  final sortedKeys = performanceByMonthAndAge.keys.toList()
                    ..sort((a, b) => DateFormat('MMMM yyyy')
                        .parse(b)
                        .compareTo(DateFormat('MMMM yyyy').parse(a)));

                  final monthYear = sortedKeys[index];
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
                            fontSize: 18,
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
                                    fontSize: 16,
                                  ),
                                ),
                                children: sortedChildren.map((childName) {
                                  final performances =
                                      performancesByChild[childName]!;
                                  performances.sort((a, b) =>
                                      DateTime.parse(a.date)
                                          .compareTo(DateTime.parse(b.date)));

                                  // Group performances by date
                                  Map<String, List<PerformanceModel>>
                                      groupedPerformances = {};
                                  for (var performance in performances) {
                                    if (!groupedPerformances
                                        .containsKey(performance.date)) {
                                      groupedPerformances[performance.date] =
                                          [];
                                    }
                                    groupedPerformances[performance.date]!
                                        .add(performance);
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: ExpansionTile(
                                        title: Text(childName),
                                        children: groupedPerformances.keys
                                            .map((date) {
                                          final performancesOnDate =
                                              groupedPerformances[date]!;

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16.0),
                                                ),
                                                ...performancesOnDate
                                                    .map((performance) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 4.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 16.0),
                                                            child: Text(
                                                                performance
                                                                    .skill),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child:
                                                              RatingBarIndicator(
                                                            rating: double.tryParse(
                                                                    performance
                                                                        .level) ??
                                                                0,
                                                            itemBuilder:
                                                                (context,
                                                                        index) =>
                                                                    Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.amber,
                                                            ),
                                                            itemCount: 3,
                                                            itemSize: 20.0,
                                                            direction:
                                                                Axis.horizontal,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
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
