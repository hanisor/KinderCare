import 'package:flutter/material.dart';
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
  Map<String, List<PerformanceModel>> performanceByMonth = {};
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

      if (response != null && response is Map<String, dynamic>) {
        final responseData = response;
        final childGroup = responseData['child_group'];

        setState(() {
          performanceByMonth.clear();

          if (childGroup is List) {
            childGroup.forEach((childGroupItem) {
              final child = childGroupItem['child'];
              final performances = childGroupItem['child']['performances'];

              if (child != null && performances is List) {
                final childName = child['name'] as String?;

                performances.forEach((performance) {
                  PerformanceModel performanceModel =
                      PerformanceModel.fromJson(performance);
                  performanceModel.childName = childName ?? 'Unknown Child';

                  final date = performanceModel.date;
                  if (date != null && date.isNotEmpty) {
                    final parsedDate = DateTime.parse(date);
                    final monthYear = DateFormat('MMMM yyyy').format(parsedDate);

                    if (!performanceByMonth.containsKey(monthYear)) {
                      performanceByMonth[monthYear] = [];
                    }
                    performanceByMonth[monthYear]?.add(performanceModel);
                  }
                });
              }
            });
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
                itemCount: performanceByMonth.keys.length,
                itemBuilder: (context, index) {
                  final monthYear = performanceByMonth.keys.elementAt(index);
                  final performances = performanceByMonth[monthYear] ?? [];

                  return Card(
                    child: ExpansionTile(
                      title: Text(monthYear),
                      children: performances.map((performance) {
                        return ListTile(
                          title: Text(performance.childName ?? 'Unknown Child'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Skill: ${performance.skill}'),
                              Text('Level: ${performance.level}'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
