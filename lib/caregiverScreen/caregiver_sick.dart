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
  DateTime? dateTime;
  List<SicknessModel> checklistItems = [];

  Future<void> fetchChecklistItems() async {
    RequestController req = RequestController(path: 'sickness-data/${widget.caregiverId}');
    await req.get();
    var response = req.result();
    print("raw response: $response");

    if (response != null && response['child_group'] is List) {
      List<dynamic> childGroupList = response['child_group'];
      DateTime now = DateTime.now();

      setState(() {
        checklistItems.clear();  // Clear the list before adding new items
      });

      for (var childGroup in childGroupList) {
        var child = childGroup['child'];
        if (child != null && child['sicknesses'] is List) {
          List<dynamic> sicknessesList = child['sicknesses'];
          ChildModel childModel = ChildModel.fromJson(child);
          for (var sickness in sicknessesList) {
            SicknessModel sicknessModel = SicknessModel.fromJson(sickness, childModel: childModel);

            // Filter by current date
            DateTime sicknessDate = DateTime.parse(sicknessModel.dateTime);
            if (sicknessDate.year == now.year && sicknessDate.month == now.month && sicknessDate.day == now.day) {
              setState(() {
                checklistItems.add(sicknessModel);
              });
            }
          }
        }
      }

      // Sort the list so that "Pending" items are on top
      checklistItems.sort((a, b) {
        if (a.sicknessStatus == 'Pending' && b.sicknessStatus == 'Taken') {
          return -1;
        } else if (a.sicknessStatus == 'Taken' && b.sicknessStatus == 'Pending') {
          return 1;
        }
        return 0;
      });
    }
  }

  Future<void> updateSicknessStatus(int? sicknessId) async {
    Map<String, dynamic> requestBody = {};
    if (sicknessStatus == "Pending") {
      requestBody["status"] = "Taken";
      sicknessStatus = "Taken";
    }

    RequestController req = RequestController(path: 'caregiver/update-sickness/$sicknessId');
    req.setBody(requestBody);
    await req.put();

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

    // Refresh data after updating the status
    await fetchChecklistItems();
  }

  Future<void> _refreshData() async {
    await fetchChecklistItems();
  }

  @override
  void initState() {
    super.initState();
    fetchChecklistItems();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Sickness checklist'),
    ),
    body: RefreshIndicator(
      onRefresh: _refreshData,
      child: checklistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No sickness checklist available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
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
                            text: '${item.childModel?.childName ?? "Unknown"}',
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
                        updateSicknessStatus(item.sicknessId);
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
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('MMMM dd, yyyy hh:mm a').format(dateTime);
  }
}
