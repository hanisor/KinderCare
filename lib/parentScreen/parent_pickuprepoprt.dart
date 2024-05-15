import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/childRelative_model.dart';
import 'package:kindercare/parentScreen/parent_pickup.dart';
import 'package:kindercare/request_controller.dart';

class ParentPickupReport extends StatefulWidget {
  final int? parentId;
  ParentPickupReport({Key? key, this.parentId});

  @override
  State<ParentPickupReport> createState() => _ParentPickupReportState();
}

class _ParentPickupReportState extends State<ParentPickupReport> {
  List<ChildRelativeModel> childRelativeList = [];

  Future<void> fetchRelative() async {
    RequestController req = RequestController(path: 'childRelative-data');

    await req.get();
    var response = req.result();
    if (response != null && response is List) {
      setState(() {
        childRelativeList = List<ChildRelativeModel>.from(response.map((x) {
          x['id'] = int.tryParse(x['id'].toString());
          return ChildRelativeModel.fromJson(x);
        }).where((item) => item.relativeModel?.status == 'ACTIVE'));

        childRelativeList.sort((a, b) {
          if (a.relativeModel?.dateTime == null ||
              b.relativeModel?.dateTime == null) {
            if (a.relativeModel?.dateTime == null &&
                b.relativeModel?.dateTime != null) {
              return 1;
            } else if (a.relativeModel?.dateTime != null &&
                b.relativeModel?.dateTime == null) {
              return -1;
            } else {
              return 0;
            }
          }
          return a.relativeModel!.dateTime.compareTo(b.relativeModel!.dateTime);
        });
      });
    }
  }

  Future<void> softDeleteRelative(int? relativeId) async {
    if (relativeId != null) {
      try {
        RequestController req =
            RequestController(path: 'relative/delete/$relativeId');
        req.setBody({"id": relativeId, "status": "INACTIVE"});
        await req.put();
        // Refresh the list after deletion
        fetchRelative();
      } catch (e) {
        print('Error deactivating relative: $e');
      }
    } else {
      print('Error: Relative ID is null');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRelative();
  }

  @override
  Widget build(BuildContext context) {
    Map<int, List<ChildRelativeModel>> childrenByRelativeId = {};
    for (var childRelative in childRelativeList) {
      if (!childrenByRelativeId.containsKey(childRelative.relativeId)) {
        childrenByRelativeId[childRelative.relativeId] = [];
      }
      childrenByRelativeId[childRelative.relativeId]!.add(childRelative);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Report'),
      ),
      body: RefreshIndicator(
        onRefresh: fetchRelative,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: childRelativeList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 300,
                          height: 200,
                          child: Center(
                            child: Text(
                              'No pickup schedule',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ParentPickup(parentId: widget.parentId),
                              ),
                            );
                          },
                          child: const Text('Add Pickup Relative'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: childrenByRelativeId.entries.map((entry) {
                      List<ChildRelativeModel> children = entry.value;
                      var relative = children.first.relativeModel;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Relative Information:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text('Name: ${relative?.name ?? ''}'),
                          Text('Relation: ${relative?.relation ?? ''}'),
                          Text('Phone Number: ${relative?.phone_number ?? ''}'),
                          Text(
                            'Pickup Date and Time: ${relative?.dateTime != null ? DateFormat.yMd().add_jm().format(DateTime.parse(relative!.dateTime)) : 'Loading...'}',
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Children Information:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          if (children.isNotEmpty)
                            Column(
                              children: children.map((childRelative) {
                                return ListTile(
                                  title: Text(
                                      'Child Name: ${childRelative.childModel!.childName}'),
                                );
                              }).toList(),
                            )
                          else
                            const Text(
                                'No children associated with this relative.'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              softDeleteRelative(relative?.relativeId);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 255, 7, 148)),
                            child: const Text(
                              'Delete Report',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255), // Custom font color
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ),
      ),
    );
  }
}
