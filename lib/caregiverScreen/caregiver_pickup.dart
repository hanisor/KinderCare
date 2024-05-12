import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/childRelative_model.dart';
import 'package:kindercare/request_controller.dart';

class CaregiverPickup extends StatefulWidget {
  const CaregiverPickup({super.key});

  @override
  State<CaregiverPickup> createState() => _CaregiverPickupState();
}

class _CaregiverPickupState extends State<CaregiverPickup> {
  List<ChildRelativeModel> childRelativeList =
      []; // List to hold checklist items

  Future<void> fetchNotesByParentId() async {
    RequestController req = RequestController(
        path: 'childRelative-data'); // Pass email as parameter

    await req.get();
    var response = req.result();
    if (response != null && response is List) {
      setState(() {
        childRelativeList = List<ChildRelativeModel>.from(response.map((x) {
          // Ensure noteId is parsed as an integer
          x['id'] = int.tryParse(x['id'].toString());
          print("childRelative id: ${x['id']}"); // Debug noteId
          return ChildRelativeModel.fromJson(x);
        }).where((item) => item.relativeModel?.status == 'ACTIVE'));

        // Sort notes by date time (optional)
        childRelativeList.sort((a, b) {
          // Check if either a or b's relativeModel or its dateTime is null
          if (a.relativeModel?.dateTime == null ||
              b.relativeModel?.dateTime == null) {
            // Handle the case where one or both are null
            // For example, if a is null but b is not, consider b "greater"
            if (a.relativeModel?.dateTime == null &&
                b.relativeModel?.dateTime != null) {
              return 1;
            } else if (a.relativeModel?.dateTime != null &&
                b.relativeModel?.dateTime == null) {
              return -1;
            } else {
              // Both are null, consider them equal
              return 0;
            }
          }

          // Both are not null, compare their dateTime values
          return a.relativeModel!.dateTime.compareTo(b.relativeModel!.dateTime);
        });

        print("Updated noteList: $childRelativeList"); // Print updated noteList

        print("Updated noteList: $childRelativeList"); // Print updated noteList
      });
    }
  }

 Future<void> updatePickup(int? relativeId) async {
  // Prepare the request body with the status "Taken"
  Map<String, dynamic> requestBody = {};

  // Find the ChildRelativeModel corresponding to the relativeId
ChildRelativeModel? item = childRelativeList.firstWhere(
  (childRelative) => childRelative.relativeId == relativeId,
  // ignore: cast_from_null_always_fails
  orElse: () => null as ChildRelativeModel,
);


  // Update the relative status
  if (item.relativeModel?.status == "ACTIVE") {
    requestBody["status"] = "INACTIVE";
    item.relativeModel?.status = "INACTIVE";
  }

  // Create an instance of RequestController
  RequestController req =
      RequestController(path: 'relative/delete/$relativeId');

  req.setBody(requestBody);
  await req.put();

  print(req.result());
  if (req.status() == 200) {
    Fluttertoast.showToast(
      msg: 'Update successfully',
      backgroundColor: Colors.white,
      textColor: Colors.red,
      gravity: ToastGravity.CENTER,
      toastLength: Toast.LENGTH_SHORT,
      fontSize: 16.0,
    );
  } else {
    Fluttertoast.showToast(
      msg: 'Update failed!',
      backgroundColor: Colors.white,
      textColor: Colors.red,
      gravity: ToastGravity.CENTER,
      toastLength: Toast.LENGTH_SHORT,
      fontSize: 16.0,
    );
  }
}


  Future<void> _refreshData() async {
    //await getChildrenData();
    await fetchNotesByParentId();
  }

  @override
  void initState() {
    super.initState();
    fetchNotesByParentId(); // Fetch checklist items when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    // Group children by relative ID
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
      body: ListView(
        children: childrenByRelativeId.entries.map((entry) {
          List<ChildRelativeModel> children = entry.value;

          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.startToEnd,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (DismissDirection direction) async {
              return await _confirmDelete(); // Function to confirm deletion
            },
            onDismissed: (direction) async {
              await updatePickup(children.first.relativeId); // Update status
            },
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Relative Name: ${children.first.relativeModel?.name ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Relation: ${children.first.relativeModel?.relation ?? ''}',
                        ),
                        Text(
                          'Phone Number: ${children.first.relativeModel?.phone_number ?? ''}',
                        ),
                        Text(
                          'Date and Time: ${_formatDateTime(children.first.relativeModel!.dateTime)}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced gap
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Children Information:', // Display "Children Information" once
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...children.map((childRelative) {
                    return ListTile(
                      title: Text(
                        childRelative.childModel?.childName ?? '',
                      ),
                      subtitle: Text(
                          'My kid number: ${childRelative.childModel?.childMykidNumber ?? ''}'), // No subtitle
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<bool?> _confirmDelete() async {
    // Implement your confirmation dialog here
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Confirmation'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    // Parse the dateTimeString to DateTime object
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Format the DateTime object in 12-hour system with AM/PM indicator
    return DateFormat('MMMM dd, yyyy hh:mm a').format(dateTime);
  }
}
