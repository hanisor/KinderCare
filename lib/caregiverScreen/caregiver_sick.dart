import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/model/sickness_model.dart';
import 'package:kindercare/request_controller.dart';
import 'package:intl/intl.dart';

class CaregiverSickness extends StatefulWidget {
  final int? caregiverId;
  CaregiverSickness({Key? key, this.caregiverId});
  @override
  State<CaregiverSickness> createState() => _CaregiverSicknessState();
}

class _CaregiverSicknessState extends State<CaregiverSickness> {
  String? sicknessType;
  String? dosage;
  String sicknessStatus = "Pending";
  DateTime? dateTime; // Changed type to DateTime
  List<ChildModel> childrenList = [];
  List<SicknessModel> checklistItems = []; // List to hold checklist items
  Map<int, bool> checkedMap = {};

  Future<void> fetchChecklistItems() async {
  RequestController req =
      RequestController(path: 'sickness-data/${widget.caregiverId}');

  await req.get();
  var response = req.result();
  print("raw response: $response"); // Print the raw response

  if (response != null && response['child_group'] is List) {
    // Clear existing checklist items before updating
    setState(() {
      checklistItems.clear();
    });

    List<dynamic> childGroupList = response['child_group'];

    for (var childGroup in childGroupList) {
      var child = childGroup['child'];
      if (child != null && child['sicknesses'] is List) {
        List<dynamic> sicknessesList = child['sicknesses'];
        ChildModel childModel =
            ChildModel.fromJson(child); // Parse child data
        print(
            "Child Model: ${childModel.childName}"); // Debug print for child model
        for (var sickness in sicknessesList) {
          if (sickness != null && sickness['status'] == "Pending") {
            setState(() {
              checklistItems.add(
                  SicknessModel.fromJson(sickness, childModel: childModel));
            });
          }
        }
      }
    }
  }
}

  Future<void> updateSicknessStatus(int? sicknessId) async {
    // Prepare the request body with the status "Taken"
    Map<String, dynamic> requestBody = {};

    if (sicknessStatus == "Pending") {
      requestBody["status"] = "Taken";
      sicknessStatus = "Taken";
    }

    // Create an instance of RequestController
    RequestController req =
        RequestController(path: 'caregiver/update-sickness/$sicknessId');

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
    await fetchChecklistItems();
  }

  @override
  void initState() {
    super.initState();
    fetchChecklistItems(); // Fetch checklist items when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sickness checklist'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: checklistItems.length,
          itemBuilder: (context, index) {
            SicknessModel item = checklistItems[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      const TextSpan(
                        text: 'Child Name: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            '${item.childModel?.childName ?? "Unknown"}', // Handle null child name
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sickness Type: ${item.sicknessType}'),
                    Text('Dosage: ${item.dosage}'),
                    Text('Date and Time: ${_formatDateTime(item.dateTime)}'),
                    Text('Status: ${item.sicknessStatus}'),
                  ],
                ),
                trailing: Checkbox(
                  value: item.sicknessStatus == 'Taken',
                  onChanged: (bool? value) {
                    setState(() {
                      item.sicknessStatus = value! ? 'Taken' : 'Pending';
                    });
                    // Call updateSicknessStatus when the checkbox is toggled
                    updateSicknessStatus(item
                        .sicknessId); // Assuming the id property is accessible
                    print(
                        'Updated status for ${item.sicknessType}: ${item.sicknessStatus}');
                  },
                ),
              ),
            );
          },
        ),
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
