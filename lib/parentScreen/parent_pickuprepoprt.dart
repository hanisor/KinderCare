import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/childRelative_model.dart';
import 'package:kindercare/model/relative_model.dart';
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
  if (widget.parentId == null) {
    print('Parent ID is null');
    return;
  }

  try {
    RequestController req = RequestController(path: 'childRelative-data');
    await req.get();
    var response = req.result();
    if (response != null && response is List) {
      setState(() {
        childRelativeList = List<ChildRelativeModel>.from(response.map((x) {
          x['id'] = int.tryParse(x['id'].toString());
          return ChildRelativeModel.fromJson(x);
        }).where((item) =>
            item.relativeModel?.status == 'ACTIVE' &&
            item.childModel?.parentId == widget.parentId));

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
  } catch (e) {
    print('Failed to fetch relatives: $e');
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

  Future<void> showDeleteConfirmationDialog(
    BuildContext context, int? relativeId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.pinkAccent, size: 28),
            SizedBox(width: 8),
            Text(
              'Are You Sure?',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.pinkAccent),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'Do you really want to remove this relative?',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              SizedBox(height: 10),
              Text(
                'We’ll miss them!',
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.pinkAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.delete_forever,
                        color: Colors.pinkAccent, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This action can’t be undone.',
                        style: TextStyle(
                            color: Colors.pinkAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Keep',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          ElevatedButton(
            onPressed: () {
              softDeleteRelative(relativeId);
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Remove',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
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
                              showDeleteConfirmationDialog(
                                  context, relative?.relativeId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Delete Report',
                              style: TextStyle(
                                color: Colors.white,
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
