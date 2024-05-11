import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/parentScreen/parent_pickup.dart';
import 'package:kindercare/request_controller.dart';
import '../model/relative_model.dart';

class ParentPickupReport extends StatefulWidget {
  final int? parentId;
  ParentPickupReport({Key? key, this.parentId});

  @override
  State<ParentPickupReport> createState() => _ParentPickupReportState();
}

class _ParentPickupReportState extends State<ParentPickupReport> {
  List<ChildModel> _children = [];
  String? relativeName;
  int? relativeId;
  String? relation;
  String? phoneNumber;
  DateTime? pickupDateTime;
  bool showAddButton = false;

  Future<void> _fetchRelativeData() async {
    try {
      RequestController req =
          RequestController(path: 'child-relatives/${widget.parentId}');
      await req.get();
      var response = req.result();

      if (response != null && response.containsKey('child_relatives')) {
        List<dynamic> relativesData = response['child_relatives'];

        setState(() {
          relativeId = relativesData[0]['id'];
          relativeName = relativesData[0]['relative_name'];
          relation = relativesData[0]['relation'];
          phoneNumber = relativesData[0]['phone_number'];
          pickupDateTime = DateTime.parse(relativesData[0]['date_time']);

          _children = relativesData.map((relative) {
            return ChildModel(
              childId: relative['child_id'],
              childName: relative['child_name'],
              childMykidNumber: "", // Dummy value for childMykidNumber
              childAge: 0, // Dummy value for childAge
              childGender: "", // Dummy value for childGender
              childAllergies: "", // Dummy value for childAllergies
              parentId: widget.parentId ?? 0, // Use parentId passed to widget
            );
          }).toList();
        });

        // Check if there are children associated with the relative
        if (_children.isEmpty) {
          showAddButton = true; // Show "Add Pickup Relative" button
        }
      } else {
        print('Error: Response does not contain the expected data structure');
      }
    } catch (e) {
      print('Error fetching relative data: $e');
    }
  }

/*  Future<void> softDeleteRelative() async {
  RequestController req = RequestController(path: 'child-relatives/delete/${widget.parentId}');
  try {
    // Perform the update operation using the put method and await it
    await req.put();

    // After successfully soft deleting the relative, update the UI
    setState(() {
      // Update UI or state variables if needed
      status = "INACTIVE"; // Update status to 'INACTIVE'
    });
  } catch (e) {
    print('Error soft deleting relative: $e');
  }
} */
// Method to update the status to INACTIVE
 Future<void> softDeleteRelative() async {
  // Ensure that relativeId is not null before proceeding
  if (relativeId != null) {
    // Send a request to the backend to update the status to INACTIVE
    try {
      // Create an instance of RequestController
      RequestController req =
          RequestController(path: 'relative/delete/${widget.parentId}');

      // Set the request body including the relative ID
      req.setBody({"id": relativeId, "status": "INACTIVE"});
      print('relativeid = $relativeId');

      // Execute the request and wait for the result
      await req.put();

     /*  // Update the UI state if needed
      setState(() {
        status = "INACTIVE";
      }); */
    } catch (e) {
      print('Error deactivating relative: $e');
    }
  } else {
    print('Error: Relative ID is null');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pickup Report'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRelativeData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relative Information:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Name: ${relativeName ?? ''}'),
                Text('Relation: ${relation ?? ''}'),
                Text('Phone Number: ${phoneNumber ?? ''}'),
                Text(
                    'Pickup Date and Time: ${pickupDateTime != null ? DateFormat.yMd().add_jm().format(pickupDateTime!) : 'Loading...'}'),
                SizedBox(height: 20),
                Text(
                  'Children Information:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (_children.isNotEmpty)
                  Column(
                    children: _children.map((child) {
                      return ListTile(
                        title: Text(child.childName ?? ''),
                        // Other child details...
                      );
                    }).toList(),
                  )
                else
                  Text('No children associated with this relative.'),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showAddButton)
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
                        child: Text('Add Pickup Relative'),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        softDeleteRelative(); // Soft delete the report
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('Delete Report'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
