import 'package:flutter/material.dart';
import 'package:kindercare/model/attendance_model.dart';
import 'package:provider/provider.dart';
import 'package:kindercare/model/child_model.dart';
import 'package:kindercare/request_controller.dart';

class ParentAttendanceArrival extends StatefulWidget {
  final int? parentId;
  ParentAttendanceArrival({Key? key, this.parentId}) : super(key: key);

  @override
  State<ParentAttendanceArrival> createState() => _ParentAttendanceArrivalState();
}

class _ParentAttendanceArrivalState extends State<ParentAttendanceArrival> {
  DateTime? dateTime; // Changed type to DateTime
  List<ChildModel> childrenList = [];

  @override
  void initState() {
    super.initState();
    getChildrenData();
    // Initialize dateTime with current date and time
    dateTime = DateTime.now();
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
    print("childrenList : $childrenList");
  }

void toggleChildSelection(ChildModel child, AttendanceModel attendanceModel) {
  if (attendanceModel.selectedChildren.contains(child)) {
    attendanceModel.removeChild(child);
  } else {
    attendanceModel.addChild(child);
  }
}


 void sendAttendanceConfirmation(BuildContext context, AttendanceModel attendanceModel, DateTime dateTime) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Selected Children"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Are you sure you want to send attendance for the following children?"),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: attendanceModel.selectedChildren.length,
              itemBuilder: (context, index) {
                return Text(attendanceModel.selectedChildren[index].childName);
              },
            ),
            const SizedBox(height: 16),
            Text("Date: ${dateTime.day}/${dateTime.month}/${dateTime.year}  Time: ${dateTime.hour}:${dateTime.minute}"),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Create a copy of selectedChildren
              final List<ChildModel> selectedChildrenCopy = List.from(attendanceModel.selectedChildren);
              // Update selectedDateTime in AttendanceModel
              attendanceModel.selectedDateTime = dateTime;
              // Pass date and time along with children details to the model
              attendanceModel.addChildWithDateTime(selectedChildrenCopy, dateTime);
              // Show SnackBar message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Attendance for your children has been sent!'),
                  duration: Duration(seconds: 2), // Adjust the duration as needed
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final attendanceModel = Provider.of<AttendanceModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        actions: [
          IconButton(
            onPressed: attendanceModel.selectedChildren.isNotEmpty
                ? () => sendAttendanceConfirmation(
                    context, attendanceModel, dateTime!)
                : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "Date: ${dateTime?.day}/${dateTime?.month}/${dateTime?.year}  Time: ${dateTime?.hour}:${dateTime?.minute}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: childrenList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: childrenList.length,
                      itemBuilder: (context, index) {
                        final child = childrenList[index];
                        final isSelected =
                            attendanceModel.selectedChildren.contains(child);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              toggleChildSelection(child, attendanceModel);
                            });
                          },
                          child: Card(
                            color: isSelected ? Colors.blue[100] : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(child.childName[0]),
                                ),
                                title: Text(child.childName),
                                subtitle: Text(
                                    'DOB: ${child.childDOB}\nGender: ${child.childGender}\nAllergies: ${child.childAllergies}'),
                                trailing: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color: isSelected ? Colors.green : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
